//
//  MetaDataItemBook.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

class TOCAudioBook {
    
    let bible: TOCAudioBible
    let bookId: String
    let bookOrder: String
    let sequence: Int
    var bookName: String // Used by AudioControlCenter
    let numberOfChapters: Int

    init(bible: TOCAudioBible, dbRow: [String?]) {
        self.bible = bible
        self.bookId = dbRow[0]!
        self.bookOrder = dbRow[1]!
        self.sequence = Int(self.bookOrder) ?? 0
        self.bookName = self.bookId // Reset by MetaDataReader.readBookNames to bookName
        let chapters = dbRow[2]!
        self.numberOfChapters = Int(chapters) ?? 1
    }
    
    deinit {
        print("***** Deinit TOCAudioBook *****")
    }
    
    func toString() -> String {
        let str = "bookId=" + self.bookId +
            ", bookOrder=" + self.bookOrder +
            ", numberOfChapter=" + String(self.numberOfChapters)
        return str
    }
}
