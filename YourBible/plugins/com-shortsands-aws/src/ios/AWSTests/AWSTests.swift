//
//  AWSTests2.swift
//  AWSTests2
//
//  Created by Gary Griswold on 10/21/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import XCTest
@testable import AWS

/**
* I never go this working 10/20/2017
*/

class AWSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        AwsS3.region = "us-west-2"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidGetURL() {
        let s3 = AwsS3.shared
        s3.preSignedUrlGET(s3Bucket: "shortsands", s3Key: "KJVPD.db.zip", expires: 3600,
                           complete: {
                            url in
                            print("computed GET URL \(String(describing: url))")
                            XCTAssert(url?.host == "s3-amazonaws.com", "Incorrect Valid Get URL")
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
