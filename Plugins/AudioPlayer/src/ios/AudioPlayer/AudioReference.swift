//
//  AudioReference.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/14/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

class AudioReference {
    
    let tocAudioBook: AudioTOCBook
    private let chapter: String
    let fileType: String
    var audioChapter: AudioTOCChapter?
    
    init(book: AudioTOCBook, chapter: String, fileType: String) {
        self.tocAudioBook = book
        self.chapter = chapter
        self.fileType = fileType
        print("***** Init AudioReference ***** \(self.toString())")
    }
    
    convenience init(book: AudioTOCBook, chapterNum: Int, fileType: String) {
        let chapter = String(chapterNum)
        switch chapter.count {
        case 1:
            self.init(book: book, chapter: "00" + chapter, fileType: fileType)
        case 2:
            self.init(book: book, chapter: "0" + chapter, fileType: fileType)
        default:
            self.init(book: book, chapter: chapter, fileType: fileType)
        }
    }
   
    deinit {
        print("***** Deinit AudioReference ***** \(self.toString())")
    }

    var textVersion: String {
        get {
            return self.tocAudioBook.testament.bible.textVersion
        }
    }
 
    var silLang: String {
        get {
            return self.tocAudioBook.testament.bible.silLang
        }
    }

    var damId: String {
        get {
            return self.tocAudioBook.testament.damId
        }
    }
  
    private var sequence: String {
        get {
            return self.tocAudioBook.bookOrder
        }
    }
 
    var sequenceNum: Int {
        get {
            return self.tocAudioBook.sequence
        }
    }
    
    var bookId: String {
        get {
            return self.tocAudioBook.bookId
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
    
    var dbpLanguageCode: String {
        get {
            return self.tocAudioBook.testament.dbpLanguageCode
        }
    }
    
    private var dbpVersionCode: String {
        get {
            return self.tocAudioBook.testament.dbpVersionCode
        }
    }
    
    private var dbpBookName: String {
        get {
            return self.tocAudioBook.dbpBookName
        }
    }
    
    func nextChapter() -> AudioReference? {
        return self.tocAudioBook.testament.nextChapter(reference: self)
    }
    
    func priorChapter() -> AudioReference? {
        return self.tocAudioBook.testament.priorChapter(reference: self)
    }
    
    func getS3Bucket() -> String {
        switch (self.fileType) {
        case "mp3": return "dbp-prod"
            default: return "unknown bucket"
        }
    }
    
    func getS3Key() -> String {
        let abbr = self.dbpLanguageCode + self.dbpVersionCode
        var chapNum = self.chapter
        if self.bookId != "PSA" {
            chapNum = "_" + String(chapNum.dropFirst(1))
        }
        var name: String = self.dbpBookName.replacingOccurrences(of: " ", with: "_")
        name = name.padding(toLength: 12, withPad: "_", startingAt: 0)
        let key = "audio/\(abbr)/\(self.damId)/\(self.sequence)__\(chapNum)_\(name)\(self.damId).\(self.fileType)"
        print("KEY: \(key)")
        return key
    }
    
    func getNodeId(verse: Int) -> String {
        if verse > 0 {
            return self.bookId + ":" + String(self.chapterNum) + ":" + String(verse)
        } else {
            return self.bookId + ":" + String(self.chapterNum)
        }
    }
    
    func isEqual(reference: AudioReference) -> Bool {
        if (self.chapter != reference.chapter) { return false }
        if (self.bookId != reference.bookId) { return false }
        if (self.sequence != reference.sequence) { return false }
        if (self.damId != reference.damId) { return false }
        if (self.fileType != reference.fileType) { return false }
        return true
    }
    
    func toString() -> String {
        return self.damId + "_" + self.sequence + "_" + self.bookId + "_" + self.chapter + "." + self.fileType
    }
}
