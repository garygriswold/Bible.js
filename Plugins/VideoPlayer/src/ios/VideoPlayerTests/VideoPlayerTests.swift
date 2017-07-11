//
//  VideoPlayerTests.swift
//  VideoPlayerTests
//
//  Created by Gary Griswold on 6/15/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import XCTest
@testable import VideoPlayer

class VideoPlayerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let player = VideoViewPlayer(
            mediaSource: "JFP",
            videoId: "Jesus",
            languageId: "530",
            silLang: "eng",
            videoUrl: "https://arc.gt/6u3oe?apiSessionId=59323fee237b64.08763601")
        player.begin(complete: { error in
            if let err = error {
                print("VideoPlayer ERROR \(err.localizedDescription)")
            } else {
                print("VideoPlayer SUCCESS")
            }
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
