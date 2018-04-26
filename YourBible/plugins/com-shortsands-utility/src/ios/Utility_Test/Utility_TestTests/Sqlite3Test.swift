//
//  Sqlite3Test.swift
//  AudioPlayerTests
//
//  Created by Gary Griswold on 11/20/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import XCTest
//@testable import Utility
import Utility

class Sqlite3Test: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateNonExistantDB() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "NonExistant.db", copyIfAbsent: false)
            assert(true)
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testNonExistantWithCopy() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "AnotherNonExistant.db", copyIfAbsent: true)
            assert(false, "Exception Expected")
        } catch Sqlite3Error.databaseNotInBundle {
            assert(true)
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    /**
    * This is succeeding, but I really wanted it to fail, because it is not a DB."
    */
    func testNonDBInBundle() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Reference.swift", copyIfAbsent: true)
            db.close()
        } catch Sqlite3Error.databaseNotInBundle {
            assert(true)
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testValidDBInBundle() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            db.close()
            assert(true)
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testInvalidSelect() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let query = "select * from NonExistantTable"
            let resultSet = try db.queryV1(sql: query, values: [])
            assert(false, "Throw should prevent this")
        } catch Sqlite3Error.statementPrepareFailed {
            assert(true)
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testValidSelectNoRows() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let query = "select * from Video where languageId is null"
            let resultSet = try db.queryV1(sql: query, values: [])
            assert(resultSet.count == 0, "There should be no rows returned")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testValidSelectRows() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let query = "select languageId, mediaId, lengthMS from Video"
            let resultSet = try db.queryV1(sql: query, values: [])
            assert(resultSet.count > 10, "There should be many rows")
            let row: [String?] = resultSet[0]
            assert(row.count == 3, "There should be 3 columns.")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func NOtestDropTableTest1() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "DROP TABLE TEST1"
            let rowCount = try db.executeV1(sql: stmt, values: [])
            assert(rowCount == 0, "Create table returns zero rowCount")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func NOtestValidCreateTable() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "CREATE TABLE TEST1(abc TEXT, def INT, ghi REAL, ijk BLOB)"
            let rowCount = try db.executeV1(sql: stmt, values: [])
            assert(rowCount == 0, "Create table returns zero rowCount")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testValidInsertText() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)"
            let vals = ["abc", "def", "ghi", "jkl"]
            let rowCount = try db.executeV1(sql: stmt, values: vals)
            assert(rowCount == 1, "Insert Text should return 1 row.")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testValidInsertInt() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)"
            let vals = ["123", "345", "678", "910"]
            let rowCount = try db.executeV1(sql: stmt, values: vals)
            assert(rowCount == 1, "Insert Int should return 1 row.")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testValidInsertReal() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "INSERT INTO TEST1 (abc, def, ghi, ijk) VALUES (?, ?, ?, ?)"
            let vals = ["12.3", "34.5", "67.8", "91.0"]
            let rowCount = try db.executeV1(sql: stmt, values: vals)
            assert(rowCount == 1, "Insert Real should return 1 row.")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testQueryV0() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "SELECT abc, def, ghi FROM TEST1"
            let resultSet = try db.queryV0(sql: stmt, values: [])
            for row in resultSet {
                let abc = row["abc"]
                let def = row["def"]
                let ghi = row["ghi"]
                print("ROW \(abc)  \(def)  \(ghi)")
            }
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testQueryJS() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "SELECT abc, def, ghi FROM TEST1"
            let resultSet = try db.queryJS(sql: stmt, values: [])
            let json = String(data: resultSet, encoding: String.Encoding.utf8)
            print("ResultSet \(json)")
        } catch let err {
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func testBulkInsert() {
        let db = Sqlite3()
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let stmt = "INSERT INTO TEST1 VALUES (?,?,?,?)"
            let values: [[Any?]] = [["one", 1, 1.12, nil],["two", 2, 2.22, nil],["three", 3, 3.33, nil]]
            let totalRowCount = try db.bulkExecuteV1(sql: stmt, values: values)
            print("total row count inserted \(totalRowCount)")
            assert((totalRowCount == 3), "rowcount should be 3")
        } catch let err {
            print(Sqlite3.errorDescription(error: err))
            assert(false, Sqlite3.errorDescription(error: err))
        }
    }
    
    func NOtestPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
