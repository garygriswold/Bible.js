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
    case columnTypeUnknown(column: String, sqliteType: String)
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
    
    public static func pathDB(dbname: String) -> URL {
        return Sqlite3().databaseDir.appendingPathComponent(dbname)
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
            NotificationCenter.default.addObserver(self, selector: #selector(safeClose(note:)),
                                                name: UIApplication.willTerminateNotification, object: nil)
        } else {
            print("SQLITE Result Code = \(result)")
            let openMsg = String.init(cString: sqlite3_errmsg(database))
            throw Sqlite3Error.databaseOpenError(name: dbname, sqliteError: openMsg)
        }
    }
    
    /** This open method is used when it is needed to open or create a database at different path
     */
    public func openLocal(path: String) throws {
        self.database = nil
        var db: OpaquePointer? = nil
        let result = sqlite3_open(path, &db)
        if result == SQLITE_OK {
            print("Successfully opened connection to database at \(path)")
            self.database = db!
        } else {
            print("SQLITE Result Code = \(result)")
            let openMsg = String.init(cString: sqlite3_errmsg(database))
            throw Sqlite3Error.databaseOpenError(name: path, sqliteError: openMsg)
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
    
    @objc func safeClose(note: NSNotification) {
        self.close()
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
    
    /**
    * This one returns its result as a single string.  It was specifically designed for returning
    * HTML rows that should be displayed consequtively, so that concatentation of the rows returns
    * a correct result.
    */
    public func queryHTMLv0(sql: String, values: [Any?]) throws -> String {
        if database != nil {
            var resultSet: String = ""
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                try self.bindStatement(statement: statement!, values: values)
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    if let cValue = sqlite3_column_text(statement, Int32(0)) {
                        resultSet += String(cString: cValue)
                    }
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
    * This query method returns its result in a proprietary format named SSIF (Short Sands Interchange Format),
    * or, Super Simple Interchange Format.  It is intended to provide the same capabilities as JSON for data
    * interchange without the process of first creating objects that must be serialized, and then desearialized
    * when received in JS.
    *
    * The format is for records that have the same number of fields in each record,
    * and each field has the same type in each record.
    * The Field delimiter is |
    * The Record delimiter is ~
    * There is no Field delimiter before the first field or after the last field in a record
    * e.g. ~ abc | def | ghi ~, because this will enable efficient splitting using JS string.split
    * There is no Record delimiter at the beginning and end of the data
    * Before adding any String to SSIF, any | and ~ character must be escaped using HTML entities.
    * These are ~ becomes &#126; and | becomes &#124;
    * Note, that \| and |~ are not used, because this would prevent the use of a simple string.split in JS
    * The first row always contains the field name for each field.
    * The second row always contains the type for each field. The types are S, I, D, B, R
    * These types are (String, Integer, Double, Boolean, Raw (which is sqlite Blob)
    * Strings are not quoted with either single or double quotes, because their type defines them as strings.
    * On the Javascript side it is expected that these would be converted using
    * parseInt(v), parseFloat(v), (v === 'true'), strings are not converted, and I am not sure how to handle blob.
    * When the string data that is returned is going to be displayed in an HTML view, there is no need to
    * unescape the HTML entity, the webview will do that.
    * Null is represented by by a zero length string.  Unfortunately, this means that we cannot distinguish
    * between a null in the database and the string "" in the database, but in JS they both return false on
    * an if (str) test.
    *
    * When this data is received on the JS side, it could be processed by a function that knows what it is expecting,
    * for type and field and skips the first two rows.  This would be the more efficient thing to do.
    * However, it is also possible for a generic SSIF.parse method to return an array of objects.
    * Consider JS classes ResultSet and ResultItem.  The ResultSet constructor would split the data into rows
    * using the ~ delimiter, and it would split the first two rows (field names and field types) using the |
    * delimiter.  The split rows would also be passed into a ResultItem constructor.  The ResultItem class has a
    * property length, that will return the number of rows split, less the names and type row.  It also has an items(i)
    * method that returns a zero relative data row.  When called on a row, it splits the row into fields and
    * creates an object with the correct field names, and with data correctly typed, using parseInt(v), parseFloat(v)
    * and (v === 'true').
    */
    public func querySSIFv0(sql: String, values: [Any?]) throws -> String {
        if database != nil {
            var resultSet = [String]()
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                try self.bindStatement(statement: statement!, values: values)
                let colCount = Int(sqlite3_column_count(statement))
                var names = [String](repeating: "", count: colCount)
                var types = [String](repeating: "S", count: colCount)
                for i in 0..<colCount {
                    let col = Int32(i)
                    names[i] = String(cString: sqlite3_column_name(statement, col))
                    let type: String = String(cString: sqlite3_column_decltype(statement, col))
                    switch type.lowercased() {
                    case "int":
                        types[i] = "I"
                        break
                    case "real":
                        types[i] = "D"
                        break
                    case "text":
                        types[i] = "S"
                        break
                    case "blob":
                        types[i] = "R"
                        break
                    default:
                        throw Sqlite3Error.columnTypeUnknown(column: names[i], sqliteType: type)
                    }
                }
                resultSet.append(names.joined(separator: "|"))
                resultSet.append(types.joined(separator: "|"))
                
                let characterset = CharacterSet(charactersIn: "|~\n\r")
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    var row = [String](repeating: "", count: colCount)
                    for i in 0..<colCount {
                        let col = Int32(i)
                        if let cValue = sqlite3_column_text(statement, col) {
                            row[i] = String(cString: cValue)
                            if types[i] == "S" && row[i].rangeOfCharacter(from: characterset) != nil {
                                let str2 = row[i].replacingOccurrences(of: "|", with: "&#124;")
                                let str3 = str2.replacingOccurrences(of: "~", with: "&#126;")
                                let str4 = str3.replacingOccurrences(of: "\r", with: "\\r")
                                row[i] = str4.replacingOccurrences(of: "\n", with: "\\n")
                            }
                        } else {
                            row[i] = ""
                        }
                    }
                    resultSet.append(row.joined(separator: "|"))
                }
                return resultSet.joined(separator: "~")
            } else {
                let prepareMsg = String.init(cString: sqlite3_errmsg(database))
                throw Sqlite3Error.statementPrepareFailed(sql: sql, sqliteError: prepareMsg)
            }
        } else {
            throw Sqlite3Error.databaseNotFound(name: "unknown")
        }
    }
    
    public func objectExists(type: String, name: String) throws -> Bool {
        if database != nil {
            var result = false
            let sql = "SELECT count(*) FROM sqlite_master WHERE type='\(type)' AND name='\(name)'"
            var statement: OpaquePointer? = nil
            let prepareOut = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if prepareOut == SQLITE_OK {
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    let count = Int(sqlite3_column_int(statement, 0))
                    result = count > 0
                }
                return result
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
            } else if value is Int64 {
                sqlite3_bind_int64(statement, col, Int64(value as! Int64))
            } else if value is Double {
                sqlite3_bind_double(statement, col, (value as! Double))
            } else if value is Bool {
                let fld = (value as! Bool) ? "T" : "F"
                sqlite3_bind_text(statement, col, (fld as NSString).utf8String, -1, nil)
            } else if value is NSNull {
                sqlite3_bind_null(statement, col)
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
            case Sqlite3Error.columnTypeUnknown(let column, let sqliteType) :
                return "ColumnTypeUnknown: col \(column) type \(sqliteType)"
            default:
                return "Unknown Sqlite3Error"
            }
        } else {
            return error.localizedDescription
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

