//
//  Reference.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/14/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

class Reference {
    
    let tocAudioBible: TOCAudioBible
    let tocAudioBook: TOCAudioBook
    let chapter: String
    let fileType: String
    var audioChapter: TOCAudioChapter?
    
    init(bible: TOCAudioBible, book: TOCAudioBook, chapter: String, fileType: String) {
        self.tocAudioBible = bible
        self.tocAudioBook = book
        self.chapter = chapter
        self.fileType = fileType
    }
    
    convenience init(bible: TOCAudioBible, book: TOCAudioBook, chapterNum: Int, fileType: String) {
        let chapter = String(chapterNum)
        switch chapter.count {
        case 1:
            self.init(bible: bible, book: book, chapter: "00" + chapter, fileType: fileType)
        case 2:
            self.init(bible: bible, book: book, chapter: "0" + chapter, fileType: fileType)
        default:
            self.init(bible: bible, book: book, chapter: chapter, fileType: fileType)
        }
    }
   
    deinit {
        print("***** Deinit Reference ***** \(self.toString())")
    }
    
    var damId: String {
        get {
            return self.tocAudioBible.damId
        }
    }
    
    var sequence: String {
        get {
            return self.tocAudioBook.bookOrder
        }
    }
    
    var sequenceNum: Int {
        get {
            return Int(self.tocAudioBook.bookOrder) ?? 1
        }
    }
    
    var book: String {
        get {
            return self.tocAudioBook.bookId
        }
    }
    
    var bookName: String {
        get {
            return self.tocAudioBook.bookName
        }
    }
    
    var chapterNum: Int {
        get {
            return Int(self.chapter) ?? 1
        }
    }
    
    var localName: String {
        get {
            return self.tocAudioBook.bookName + " " + String(Int(self.chapter) ?? 1)
        }
    }
    
    func getS3Bucket() -> String {
        switch (self.fileType) {
            case "mp3": return self.damId.lowercased() + ".shortsands.com"
            default: return "unknown bucket"
        }
    }
    
    func getS3Key() -> String {
        return self.sequence + "_" + self.book + "_" + self.chapter + "." + self.fileType
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
