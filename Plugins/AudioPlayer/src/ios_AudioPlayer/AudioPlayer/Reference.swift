//
//  Reference.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/14/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation


class Reference {
    
    //let damId: String
    let sequence: String
    let book: String
    let chapter: String
    //? let verse: Int
    
    init(sequence: String, book: String, chapter: String) {
        self.sequence = sequence
        self.book = book
        self.chapter = chapter
    }
    
    deinit {
        print("Reference was deinitialized")
    }
    
    var sequenceNum: Int {
        get {
            return Int(self.sequence) ?? 1
        }
    }
    
    var chapterNum: Int {
        get {
            return Int(self.chapter) ?? 1
        }
    }
    
    func getS3Key(damId: String, fileType: String) -> String {
        return damId + "_" + self.sequence + "_" + self.book + "_" + self.chapter + "." + fileType
    }
}
