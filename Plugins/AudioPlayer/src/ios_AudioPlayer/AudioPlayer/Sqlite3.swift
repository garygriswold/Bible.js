//
//  Sqlite.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 11/13/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import SQLite3

class Sqlite3 {
    
    // Have static member and method to set the database location?
    // Or, do I include the database location with each init?
    // Or, do I have enum values for various locations?
    
    public let isOpen: Bool
    private let database: OpaquePointer?
    
    
    init(dbPath: String, copyIfAbsent: Bool) {
        if let fullPath = ensureDatabase(dbPath: dbPath, copyIfAbsent: copyIfAbsent) {
        
            var db: OpaquePointer? = nil
            if sqlite3_open(fullPath, &db) == SQLITE_OK {
                print("Successfully opened connection to database at \(fullPath)")
                self.database = db!
                self.isOpen = true
            } else {
                print("Unable to open database. Verify that you created the directory described " +
                    "in the Getting Started section.")
                self.database = nil
                self.isOpen = false
            }
        } else {
            self.database = nil
            self.isOpen = false
        }
    }
    
    private func ensureDatabase(dbPath: String, copyIfAbsent: Bool) -> String? {
        // compute full path
        // check if present
        // if present return fullPath
        // else
        //   if not copy if absent return nil
        //   if copy If Absent
        //      compute bundle path
        //      check if present
        //      if not present return nil
        //      if present
        //        use FileManager to copy from bundle to fullPath
        //      if
        return nil
    }
    
    deinit {
        print("****** Deinit Sqlite ******")
    }
    
    func close() {
        sqlite3_close(database)
    }
    
    /**
    * This select statement returns an array of rows of string arrays.
    * Column values are found in the result set by ordinal position in the query.
    * For simplicity all results are String, and this is also most efficient, because
    * Almost all values in sqlite are stored as cstrings.
    */
    func stringSelect(query: String, complete: @escaping (_ results:[String?]) -> Void) {
        var resultSet: [[String?]] = []
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let colCount = Int(sqlite3_column_count(statement))
                var row: [String?] = [String?] (repeating: nil, count: colCount)
                for i in 0..<colCount {
                    if let cValue = sqlite3_column_text(statement, Int32(i)) {
                        let value = String(cString: cValue)
                        row[i] = value
                    } else {
                        row[i] = nil
                    }
                }
                resultSet.append(row)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(statement)
    }
}

// Results could be : [Dictionary<String, String>]


//sqlite3_column_name(<#T##OpaquePointer!#>, <#T##N: Int32##Int32#>)
//sqlite3_column_type(<#T##OpaquePointer!#>, <#T##iCol: Int32##Int32#>)
