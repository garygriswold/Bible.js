//
//  TOCAudioBibleTest.swift
//  AudioPlayerTests
//
//  Created by Gary Griswold on 10/2/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import XCTest
import AudioPlayer

class TOCAudioBibleTest: XCTestCase {
    
    var audioChapter: AudioTOCChapter?
    
    override func setUp() {
        super.setUp()
        if audioChapter == nil {
            let reader = AudioTOCBible()
            reader.readVerseAudio(damid: "DEMO", bookId: "TST", chapter: 1, complete: {
                audioChapter in
                self.audioChapter = audioChapter
                print("PARSED DATA \(self.audioChapter?.toString())")
            })
        }
    }
    override func tearDown() {
        super.tearDown()
    }
    func testMatch_4_30() {
        self.doTest(priorVerse: 4, seconds: 30, expectVerse: 4)
    }
    func testVerse_0_0() {
        self.doTest(priorVerse: 0, seconds: 0.0, expectVerse: 1)
    }
    func testVerse_0_1() {
        self.doTest(priorVerse: 0, seconds: 1.0, expectVerse: 1)
    }
    func testVerseFind_0_35() {
        doTest(priorVerse: 0, seconds: 35.0, expectVerse: 4)
    }
    func testVerseFind_0_40() {
        doTest(priorVerse: 0, seconds: 40, expectVerse: 5)
    }
    func testVerseFind_0_495() {
        doTest(priorVerse: 0, seconds: 495, expectVerse: 50)
    }
    func testVerseFind_0_515() {
        doTest(priorVerse: 0, seconds: 515, expectVerse: 51)
    }
    func testVerseFind_0_1000() {
        doTest(priorVerse: 0, seconds: 1000.0, expectVerse: 51)
    }
    func testVerse_1_0() {
        self.doTest(priorVerse: 1, seconds: 0.0, expectVerse: 1)
    }
    func testVerse_1_1() {
        self.doTest(priorVerse: 1, seconds: 1.0, expectVerse: 1)
    }
    func testVerseFind_2_35() {
        doTest(priorVerse: 2, seconds: 35.0, expectVerse: 4)
    }
    func testVerseFind_3_40() {
        doTest(priorVerse: 3, seconds: 40, expectVerse: 5)
    }
    func testVerseFind_10_495() {
        doTest(priorVerse: 10, seconds: 495, expectVerse: 50)
    }
    func testVerseFind_15_515() {
        doTest(priorVerse: 15, seconds: 515, expectVerse: 51)
    }
    func testVerseFind_15_1000() {
        doTest(priorVerse: 15, seconds: 1000.0, expectVerse: 51)
    }
    func testVerse_5_0() {
        self.doTest(priorVerse: 5, seconds: 0.0, expectVerse: 1)
    }
    func testVerse_5_1() {
        self.doTest(priorVerse: 5, seconds: 1.0, expectVerse: 1)
    }
    func testVerse_5_10() {
        self.doTest(priorVerse: 5, seconds: 10.0, expectVerse: 2)
    }
    func testVerse_5_12() {
        self.doTest(priorVerse: 5, seconds: 10.0, expectVerse: 2)
    }
    func testVerseFind_5_22() {
        doTest(priorVerse: 5, seconds: 22.0, expectVerse: 3)
    }
    func testVerseFind_5_32() {
        doTest(priorVerse: 5, seconds: 32.0, expectVerse: 4)
    }
    func testVerse_5_42() {
        self.doTest(priorVerse: 5, seconds: 42.0, expectVerse: 5)
    }
    func testVerseFind_minus_0() {
        doTest(priorVerse: -2, seconds: 0.0, expectVerse: 1)
    }
    func testVerseFind_1_minus() {
        doTest(priorVerse: 1, seconds: -10.0, expectVerse: 1)
    }
    func testVerseFind_5_minus() {
        doTest(priorVerse: 5, seconds: -10.0, expectVerse: 1)
    }
    func testVerseFind_minus_minus() {
        doTest(priorVerse: -2, seconds: -10.0, expectVerse: 1)
    }
    private func doTest(priorVerse: Int, seconds: Double, expectVerse: Int) {
        if let chapter = self.audioChapter {
            let resultVerse = chapter.findVerseByPosition(priorVerse: priorVerse, seconds: seconds)
            assert((resultVerse == expectVerse),
                "Verse prior \(priorVerse), seconds \(seconds), expect \(expectVerse), found \(resultVerse)")
        } else {
            assert(false, "NOT READY: Verse prior \(priorVerse), seconds \(seconds)")
        }
    }
    
    func NO_testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
