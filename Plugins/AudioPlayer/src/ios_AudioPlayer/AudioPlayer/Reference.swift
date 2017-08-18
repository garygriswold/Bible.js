//
//  Reference.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/14/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation


class Reference {
    
    let sequence: String
    let book: String
    let chapter: String
    
    init(sequence: String, book: String, chapter: String) {
        self.sequence = sequence
        self.book = book
        self.chapter = chapter
    }
    
    init(string: String) {
        let parts = string.components(separatedBy: "_")
        self.sequence = parts[0]
        self.book = (parts.count > 1) ? parts[1] : ""
        self.chapter = (parts.count > 2) ? parts[2] : ""
    }
    
    deinit {
        print("Reference was deinitialized \(self.toString())")
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
    
    func isEqual(reference: Reference) -> Bool {
        if (self.chapter != reference.chapter) { return false }
        if (self.book != reference.book) { return false }
        if (self.sequence != reference.sequence) { return false }
        return true
    }
    
    func toString() -> String {
        return(self.sequence + "_" + self.book + "_" + self.chapter)
    }
}
