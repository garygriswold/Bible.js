//
//  AWSTests2.swift
//  AWSTests2
//
//  Created by Gary Griswold on 4/6/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import XCTest
import Foundation
@testable import AWS
import AWSCore

class AWSTests2: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let s3 = AwsS3.shared
        print("Start WEB.db GET \(CFAbsoluteTimeGetCurrent())")
        let filePath1 = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/WEB.db.zip")
        s3.downloadFile(s3Bucket: "shortsands", s3Key: "WEB.db.zip", filePath: filePath1,
                        complete: { err in print("I RECEIVED testDownloadFile CALLBACK \(String(describing: err))")
                            print("End WEB.db GET \(CFAbsoluteTimeGetCurrent())")
        })
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
