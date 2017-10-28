//
//  Reference.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/14/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
import AWS

class Reference {
    
    let damId: String
    let sequence: String
    let book: String
    let chapter: String
    let fileType: String
    var audioChapter: TOCAudioChapter?
    
    init(damId: String, sequence: String, book: String, chapter: String, fileType: String) {
        self.damId = damId
        self.sequence = sequence
        self.book = book
        self.chapter = chapter
        self.fileType = fileType
    }
   
    deinit {
        print("***** Deinit Reference ***** \(self.toString())")
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
    
    func getS3Bucket() -> String {
        switch (self.fileType) {
            case "mp3": return "audio-" + AwsS3.region + "-shortsands";
            default: return "unknown";
        }
    }
    
    func getS3Key() -> String {
        return self.damId + "_" + self.sequence + "_" + self.book + "_" + self.chapter + "." + self.fileType
    }
    
    func isEqual(reference: Reference) -> Bool {
        if (self.chapter != reference.chapter) { return false }
        if (self.book != reference.book) { return false }
        if (self.sequence != reference.sequence) { return false }
        if (self.damId != reference.damId) { return false }
        if (self.fileType != reference.fileType) { return false }
        return true
    }
    
    func toString() -> String {
        return self.damId + "_" + self.sequence + "_" + self.book + "_" + self.chapter + "." + self.fileType
    }
}
