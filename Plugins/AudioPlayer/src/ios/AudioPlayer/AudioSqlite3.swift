//
//  Sqlite.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 11/13/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
// Documentation of the sqlite3 C interface
// https://www.sqlite.org/cintro.html
//

import Foundation
import SQLite3

enum Sqlite3Error: Error {
    case directoryCreateError(name: String, srcError: Error)
    case databaseNotFound(name: String)
    case databaseNotInBundle(name: String)
    case databaseCopyError(name: String, srcError: Error)
    case databaseOpenError(name: String, sqliteError: String)
    case statementPrepareFailed(sql: String, sqliteError: String)
    case statementExecuteFailed(sql: String, sqliteError: String)
}

class AudioSqlite3 {
    
    private var databaseDir: URL
    private var database: OpaquePointer?
    
    init() {
        print("****** Init AudioSqlite3 ******")
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        let dbDir: URL = libDir.appendingPathComponent("LocalDatabase") // Is this the correct name?

        self.databaseDir = dbDir
        self.database = nil
    }
    // Could introduce alternate init that introduces different databaseDir
    
    deinit {
        print("****** Deinit AudioSqlite ******")
    }

    public var isOpen: Bool {
        get {
            return self.database != nil
        }
    }
  
    public func open(dbPath: String, copyIfAbsent: Bool) throws {
        self.database = nil
        try self.ensureDirectory()
        let fullPath = try self.ensureDatabase(dbPath: dbPath, copyIfAbsent: copyIfAbsent)
        
        var db: OpaquePointer? = nil
        let result = sqlite3_open(fullPath.path, &db)
        if result == SQLITE_OK {
            print("Successfully opened connection to database at \(fullPath)")
            self.database = db!
        } else {
            print("SQLITE Result Code = \(result)")
            let openMsg = String.init(cString: sqlite3_errmsg(database))
            throw Sqlite3Error.databaseOpenError(name: dbPath, sqliteError: openMsg)
        }
    }
    
    private func ensureDatabase(dbPath: String, copyIfAbsent: Bool) throws -> URL {
        let fullPath: URL = self.databaseDir.appendingPathComponent(dbPath)
        print("Opening Database at \(fullPath.path)")
        if FileManager.default.isReadableFile(atPath: fullPath.path) {
            return fullPath
        } else if copyIfAbsent {
            print("Copy Bundle at \(dbPath)")
            let parts = dbPath.split(separator: ".")
            let name = String(parts[0])
            let ext = String(parts[1])
            let bundle = Bundle.main
            let bundlePath = bundle.url(forResource: name, withExtension: ext)
            if bundlePath != nil {
                do {
                    try FileManager.default.copyItem(at: bundlePath!, to: fullPath)
                    return fullPath
                } catch let err {
                    throw Sqlite3Error.databaseCopyError(name: dbPath, srcError: err)
                }
            } else {
                throw Sqlite3Error.databaseNotInBundle(name: dbPath)
            }
        } else {
            throw Sqlite3Error.databaseNotFound(name: dbPath)
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
    public func executeV1(sql: String, values: [String?]?, complete: @escaping (_ count: Int) -> Void) throws {
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
     * This execute accepts only strings on the understanding that sqlite will convert data into the type
     * that is correct based on the affinity of the type in the database.
     *
     * Also, this query method returns a resultset that is an array of an array of Strings.
     */
    public func queryV1(sql: String, values: [String?]?, complete: @escaping (_ results:[[String?]]) -> Void) throws {
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

// Results could be : [Dictionary<String, String>]
// sqlite3_column_name(<#T##OpaquePointer!#>, <#T##N: Int32##Int32#>)
// sqlite3_column_type(<#T##OpaquePointer!#>, <#T##iCol: Int32##Int32#>)
