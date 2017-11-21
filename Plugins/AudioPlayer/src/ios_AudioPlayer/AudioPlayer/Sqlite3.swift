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
    case databaseOpenError(name: String, sqliteError: Int32)
    case selectPrepareFailed(statement: String, sqliteError: Int32)
}

class Sqlite3 {
    
    private var databaseDir: URL
    private var database: OpaquePointer?
    
    init() {
        print("****** Init Sqlite3 ******")
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        let dbDir: URL = libDir.appendingPathComponent("LocalDatabase") // Is this the correct name?

        self.databaseDir = dbDir
        self.database = nil
    }
    // Could introduce alternate init that introduces different databaseDir
    
    deinit {
        print("****** Deinit Sqlite ******")
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
            throw Sqlite3Error.databaseOpenError(name: dbPath, sqliteError: result)
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
    * This select statement returns an array of rows of string arrays.
    * Column values are found in the result set by ordinal position in the query.
    * For simplicity all results are String, and this is also most efficient, because
    * Almost all values in sqlite are stored as cstrings.
    */
    public func stringSelect(query: String, complete: @escaping (_ results:[[String?]]) -> Void) throws {
        if database != nil {
            var resultSet: [[String?]] = []
            var statement: OpaquePointer? = nil
            let result = sqlite3_prepare_v2(database, query, -1, &statement, nil)
            defer { sqlite3_finalize(statement) }
            if result == SQLITE_OK {
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
                throw Sqlite3Error.selectPrepareFailed(statement: query, sqliteError: result)
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
            case Sqlite3Error.selectPrepareFailed(let statement, let sqliteError) :
                return "SelectPrepareFailed: \(sqliteError)  on stmt: \(statement)"
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
