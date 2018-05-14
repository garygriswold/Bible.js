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
    case databaseColBindError(value: Any)
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
    public static func closeAllDB() {
        for (_, openDB) in openDatabases {
            openDB.close()
        }
        openDatabases.removeAll()
    }
    public static func listDB() throws -> [String] {
        var results = [String]()
        let db = Sqlite3()
        let files = try FileManager.default.contentsOfDirectory(atPath: db.databaseDir.path)
        for file in files {
            if file.hasSuffix(".db") {
                results.append(file)
            }
        }
        return results
    }
    public static func deleteDB(dbname: String) throws {
        let db = Sqlite3()
        let fullPath: URL = db.databaseDir.appendingPathComponent(dbname)
        try FileManager.default.removeItem(at: fullPath)
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
            var bundlePath = bundle.url(forResource: name, withExtension: ext, subdirectory: "www")
            if bundlePath == nil {
                // This option is here only because I have not been able to get databases in www in my projects
                bundlePath = bundle.url(forResource: name, withExtension: ext)
            }
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
     * This is the single statement execute
     */
    public func executeV1(sql: String, values: [Any?]) throws -> Int {
        if database != nil {
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                try self.bindStatement(statement: statement!, values: values)
                let stepOut = sqlite3_step(statement)
                if stepOut == SQLITE_DONE {
                    let rowCount = Int(sqlite3_changes(database))
                    return rowCount
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
    
    /*
    * This method executes an array of values against one prepared statement
    */
    public func bulkExecuteV1(sql: String, values: [[Any?]]) throws -> Int {
        var totalRowCount = 0
        if database != nil {
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                for row: [Any?] in values {
                    try self.bindStatement(statement: statement!, values: row)
                    if sqlite3_step(statement) == SQLITE_DONE {
                        let rowCount = Int(sqlite3_changes(database))
                        totalRowCount += rowCount
                        sqlite3_reset(statement);
                    } else {
                        let execMsg = String.init(cString: sqlite3_errmsg(database))
                        throw Sqlite3Error.statementExecuteFailed(sql: sql, sqliteError: execMsg)
                    }
                }
                return totalRowCount
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
    public func queryJS(sql: String, values: [Any?]) throws -> Data {
        let results: [Dictionary<String,Any?>] = try self.queryV0(sql: sql, values: values)
        var message: Data
        do {
            message = try JSONSerialization.data(withJSONObject: results)
        } catch let jsonError {
            print("ERROR while converting resultSet to JSON \(jsonError)")
            let errorMessage = "{\"Error\": \"Sqlite3.queryJS \(jsonError.localizedDescription)\"}"
            message = errorMessage.data(using: String.Encoding.utf8)!
        }
        return message
    }
    
    /**
     * This returns a classic sql result set as an array of dictionaries.  It is probably not a good choice
     * if a large number of rows are returned.  It returns types: String, Int, Double, and nil because JSON
     * will accept these types.
     */
    public func queryV0(sql: String, values: [Any?]) throws -> [Dictionary<String,Any?>] {
        if database != nil {
            var resultSet = [Dictionary<String,Any?>]()
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                try self.bindStatement(statement: statement!, values: values)
                let colCount = Int(sqlite3_column_count(statement))
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    var row = Dictionary<String, Any?>()
                    for i in 0..<colCount {
                        let col = Int32(i)
                        let name = String(cString: sqlite3_column_name(statement, col))
                        let type: Int32 = sqlite3_column_type(statement, col)
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
                return resultSet
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
    public func queryV1(sql: String, values: [Any?]) throws -> [[String?]] {
        if database != nil {
            var resultSet: [[String?]] = []
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                try self.bindStatement(statement: statement!, values: values)
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
                return resultSet
            } else {
                let prepareMsg = String.init(cString: sqlite3_errmsg(database))
                throw Sqlite3Error.statementPrepareFailed(sql: sql, sqliteError: prepareMsg)
            }
        } else {
            throw Sqlite3Error.databaseNotFound(name: "unknown")
        }
    }
    
    private func bindStatement(statement: OpaquePointer, values: [Any?]) throws {
        for i in 0..<values.count {
            let col = Int32(i + 1)
            let value = values[i];
            if value is String {
                sqlite3_bind_text(statement, col, (value as! NSString).utf8String, -1, nil)
            } else if value is Int {
                sqlite3_bind_int(statement, col, Int32(value as! Int))
            } else if value is Double {
                sqlite3_bind_double(statement, col, (value as! Double))
            } else if value == nil {
                sqlite3_bind_null(statement, col)
            } else {
                throw Sqlite3Error.databaseColBindError(value: value!)
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
            case Sqlite3Error.databaseColBindError(let value) :
                return "DatabaseBindError: value: \(value)"
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

