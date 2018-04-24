//
//  Sqlite3.swift
//  Utility
//
//  Created by Gary Griswold on 4/19/2019.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// Documentation of the sqlite3 C interface
// https://www.sqlite.org/cintro.html
//

import Foundation
import SQLite3

public enum Sqlite3Error: Error {
    case databaseNotOpenError(name: String)
    case directoryCreateError(name: String, srcError: Error)
    case databaseNotFound(name: String)
    case databaseNotInBundle(name: String)
    case databaseCopyError(name: String, srcError: Error)
    case databaseOpenError(name: String, sqliteError: String)
    case statementPrepareFailed(sql: String, sqliteError: String)
    case statementExecuteFailed(sql: String, sqliteError: String)
}

public class Sqlite3 {
    
    private static var openDatabases = Dictionary<String, Sqlite3>()
    public static func findDB(dbname: String) throws -> Sqlite3 {
        if let openDB: Sqlite3 = openDatabases[dbname] {
            return openDB
        } else {
            throw Sqlite3Error.databaseNotOpenError(name: dbname)
        }
    }
    public static func openDB(dbname: String, copyIfAbsent: Bool) throws -> Sqlite3 {
        if let openDB: Sqlite3 = openDatabases[dbname] {
            return openDB
        } else {
            let newDB = Sqlite3()
            try newDB.open(dbname: dbname, copyIfAbsent: copyIfAbsent)
            openDatabases[dbname] = newDB
            return newDB
        }
    }
    public static func closeDB(dbname: String) {
        if let openDB: Sqlite3 = openDatabases[dbname] {
            openDB.close()
            openDatabases.removeValue(forKey: dbname)
        }
    }
    
    
    private var databaseDir: URL
    private var database: OpaquePointer?
    
    public init() {
        print("****** Init Sqlite3 ******")
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        let dbDir: URL = libDir.appendingPathComponent("LocalDatabase")
        
        self.databaseDir = dbDir
        self.database = nil
    }
    // Could introduce alternate init that introduces different databaseDir
    
    deinit {
        print("****** Deinit Sqlite3 ******")
    }
    
    public var isOpen: Bool {
        get {
            return self.database != nil
        }
    }
    
    public func open(dbname: String, copyIfAbsent: Bool) throws {
        self.database = nil
        let fullPath = try self.ensureDatabase(dbname: dbname, copyIfAbsent: copyIfAbsent)
        
        var db: OpaquePointer? = nil
        let result = sqlite3_open(fullPath.path, &db)
        if result == SQLITE_OK {
            print("Successfully opened connection to database at \(fullPath)")
            self.database = db!
        } else {
            print("SQLITE Result Code = \(result)")
            let openMsg = String.init(cString: sqlite3_errmsg(database))
            throw Sqlite3Error.databaseOpenError(name: dbname, sqliteError: openMsg)
        }
    }
    
    /** This open method is used by command line or other programs that open the database at a
     * specified path, not in the bundle.
     */
    public func openLocal(dbname: String) throws {
        self.database = nil
        var db: OpaquePointer? = nil
        let result = sqlite3_open(dbname, &db)
        if result == SQLITE_OK {
            print("Successfully opened connection to database at \(dbname)")
            self.database = db!
        } else {
            print("SQLITE Result Code = \(result)")
            let openMsg = String.init(cString: sqlite3_errmsg(database))
            throw Sqlite3Error.databaseOpenError(name: dbname, sqliteError: openMsg)
        }
    }
    
    private func ensureDatabase(dbname: String, copyIfAbsent: Bool) throws -> URL {
        let fullPath: URL = self.databaseDir.appendingPathComponent(dbname)
        print("Opening Database at \(fullPath.path)")
        if FileManager.default.isReadableFile(atPath: fullPath.path) {
            return fullPath
        } else if !copyIfAbsent {
            try self.ensureDirectory()
            return fullPath
        } else {
            print("Copy Bundle at \(dbname)")
            try self.ensureDirectory()
            let parts = dbname.split(separator: ".")
            let name = String(parts[0])
            let ext = String(parts[1])
            let bundle = Bundle.main
            
            print("bundle \(bundle.bundlePath)")
            let bundlePath = bundle.url(forResource: name, withExtension: ext, subdirectory: "www")
            if bundlePath != nil {
                do {
                    try FileManager.default.copyItem(at: bundlePath!, to: fullPath)
                    return fullPath
                } catch let err {
                    throw Sqlite3Error.databaseCopyError(name: dbname, srcError: err)
                }
            } else {
                throw Sqlite3Error.databaseNotInBundle(name: dbname)
            }
        }
    }
    
    private func ensureDirectory() throws {
        let file = FileManager.default
        if !file.fileExists(atPath: self.databaseDir.path) {
            do {
                try file.createDirectory(at: self.databaseDir, withIntermediateDirectories: true, attributes: nil)
            } catch let err {
                throw Sqlite3Error.directoryCreateError(name: self.databaseDir.path, srcError: err)
            }
        }
    }
    
    public func close() {
        if database != nil {
            sqlite3_close(database)
            database = nil
        }
    }
    
    /**
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     */
    public func executeV1(sql: String, values: [String?], complete: @escaping (_ count: Int) -> Void) throws {
        if database != nil {
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                self.bindStatement(statement: statement!, values: values)
                let stepOut = sqlite3_step(statement)
                if stepOut == SQLITE_DONE {
                    let rowCount = Int(sqlite3_changes(database))
                    complete(rowCount)
                    
                } else {
                    let execMsg = String.init(cString: sqlite3_errmsg(database))
                    throw Sqlite3Error.statementExecuteFailed(sql: sql, sqliteError: execMsg)
                }
            } else {
                let prepareMsg = String.init(cString: sqlite3_errmsg(database))
                throw Sqlite3Error.statementPrepareFailed(sql: sql, sqliteError: prepareMsg)
            }
        } else {
            throw Sqlite3Error.databaseNotFound(name: "unknown")
        }
    }
 
    /**
     * This one is written to conform to the query interface of the cordova sqlite plugin.  It returns
     * a JSON array that can be serialized and sent back to Javascript.  It supports both String and Int
     * results, because that is what are used in the current databases.
     */
    public func queryJS(sql: String, values: [String?], complete: @escaping (_ results: Data) -> Void) throws {
        try queryV0(sql: sql, values: values, complete: { results in
            var message: Data
            do {
                message = try JSONSerialization.data(withJSONObject: results)//,
                                                     //options: JSONSerialization.WritingOptions.prettyPrinted)
            } catch let jsonError {
                print("ERROR while converting resultSet to JSON \(jsonError)")
                let errorMessage = "{\"Error\": \"Sqlite3.queryJS \(jsonError.localizedDescription)\"}"
                message = errorMessage.data(using: String.Encoding.utf8)!
            }
            complete(message)
        })
    }
    
    /**
     * This returns a classic sql result set as an array of dictionaries.  It is probably not a good choice
     * if a large number of rows are returned.  It returns types: String, Int, Double, and nil because JSON
     * will accept these types.
     */
    public func queryV0(sql: String, values: [String?],
                        complete: @escaping (_ results: [Dictionary<String,Any?>]) -> Void) throws {
        if database != nil {
            var resultSet = [Dictionary<String,Any?>]()
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                self.bindStatement(statement: statement!, values: values)
                let colCount = Int(sqlite3_column_count(statement))
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    var row = Dictionary<String, Any?>()
                    for i in 0..<colCount {
                        let col = Int32(i)
                        let name = String(cString: sqlite3_column_name(statement, col))
                        let type: Int32 = sqlite3_column_type(statement, col)
                        if name == "html" {
                            print("Found \(col) \(name) \(type)")
                        }
                        switch type {
                        case 1: // INT
                            row[name] = Int(sqlite3_column_int(statement, col))
                            break
                        case 2: // Double
                            row[name] = sqlite3_column_double(statement, col)
                            break
                        case 3: // TEXT
                            row[name] = String(cString: sqlite3_column_text(statement, col))
                            break
                        case 5: // NULL
                            row[name] = nil
                            break
                        default:
                            row[name] = String(cString: sqlite3_column_text(statement, col))
                            break
                        }
                    }
                    resultSet.append(row)
                }
                complete(resultSet)
            } else {
                let prepareMsg = String.init(cString: sqlite3_errmsg(database))
                throw Sqlite3Error.statementPrepareFailed(sql: sql, sqliteError: prepareMsg)
            }
        } else {
            throw Sqlite3Error.databaseNotFound(name: "unknown")
        }
    }
    
    /**
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     *
     * Also, this query method returns a resultset that is an array of an array of Strings.
     */
    public func queryV1(sql: String, values: [String?], complete: @escaping (_ results:[[String?]]) -> Void) throws {
        if database != nil {
            var resultSet: [[String?]] = []
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                self.bindStatement(statement: statement!, values: values)
                let colCount = Int(sqlite3_column_count(statement))
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    var row: [String?] = [String?] (repeating: nil, count: colCount)
                    for i in 0..<colCount {
                        if let cValue = sqlite3_column_text(statement, Int32(i)) {
                            row[i] = String(cString: cValue)
                        } else {
                            row[i] = nil
                        }
                    }
                    resultSet.append(row)
                }
                complete(resultSet)
            } else {
                let prepareMsg = String.init(cString: sqlite3_errmsg(database))
                throw Sqlite3Error.statementPrepareFailed(sql: sql, sqliteError: prepareMsg)
            }
        } else {
            throw Sqlite3Error.databaseNotFound(name: "unknown")
        }
    }
    
    private func bindStatement(statement: OpaquePointer, values: [String?]?) {
        if let params = values {
            for i in 0..<params.count {
                let col = Int32(i + 1)
                if let param = params[i] {
                    sqlite3_bind_text(statement, col, (param as NSString).utf8String, -1, nil)
                } else {
                    sqlite3_bind_null(statement, col)
                }
            }
        }
    }
    
    public static func errorDescription(error: Error) -> String {
        if error is Sqlite3Error {
            switch error {
            case Sqlite3Error.databaseNotOpenError(let name) :
                return "DatabaseNotOpen: \(name)"
            case Sqlite3Error.directoryCreateError(let name, let srcError) :
                return "DirectoryCreateError \(srcError)  at \(name)"
            case Sqlite3Error.databaseNotFound(let name) :
                return "DatabaseNotFound: \(name)"
            case Sqlite3Error.databaseNotInBundle(let name) :
                return "DatabaseNotInBundle: \(name)"
            case Sqlite3Error.databaseCopyError(let name, let srcError) :
                return "DatabaseCopyError: \(srcError.localizedDescription)  \(name)"
            case Sqlite3Error.databaseOpenError(let name, let sqliteError) :
                return "SqliteOpenError: \(sqliteError)  on database: \(name)"
            case Sqlite3Error.statementPrepareFailed(let sql, let sqliteError) :
                return "StatementPrepareFailed: \(sqliteError)  on stmt: \(sql)"
            case Sqlite3Error.statementExecuteFailed(let sql, let sqliteError) :
                return "StatementExecuteFailed: \(sqliteError)  on stmt: \(sql)"
            default:
                return "Unknown Sqlite3Error"
            }
        } else {
            return "Unknown Error Type"
        }
    }
}

/*
 One person's recommendation to make sqlite threadsafe.
 
 
 +(sqlite3*) getInstance {
 if (instance == NULL) {
 sqlite3_shutdown();
 sqlite3_config(SQLITE_CONFIG_SERIALIZED);
 sqlite3_initialize();
 
 NSLog(@"isThreadSafe %d", sqlite3_threadsafe());
 
 const char *path = [@"./path/to/db/db.sqlite" cStringUsingEncoding:NSUTF8StringEncoding];
 
 if (sqlite3_open_v2(path, &database, SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX, NULL) != SQLITE_OK) {
 NSLog(@"Database opening failed!");
 }
 }
 
 return instance;
 }
 */

