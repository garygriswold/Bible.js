//
//  Utility_TestTests.swift
//  Utility_TestTests
//
//  Created by Gary Griswold on 4/19/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import XCTest
import Utility

class Utility_TestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDirectoryList() {
        do {
            let files = try Sqlite3.listDB()
        } catch let err {
            print("ERROR \(err)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
