//
//  AudioTOCBook.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

class AudioTOCBook {
    
    let testament: AudioTOCTestament
    let bookId: String
    let bookOrder: String
    let sequence: Int
    let dbpBookName: String
    var bookName: String // Used by AudioControlCenter
    let numberOfChapters: Int

    init(testament: AudioTOCTestament, index: Int, dbRow: [String?]) {
        self.testament = testament
        self.bookId = dbRow[0]!
        self.bookOrder = dbRow[1]!
        self.sequence = index
        self.dbpBookName = dbRow[2]!
        self.bookName = self.dbpBookName // Reset by MetaDataReader.readBookNames to bookName
        let chapters = dbRow[3]!
        self.numberOfChapters = Int(chapters) ?? 1
    }
    
    deinit {
        print("***** Deinit AudioTOCBook *****")
    }
    
    func toString() -> String {
        let str = "bookId=" + self.bookId +
            ", bookOrder=" + self.bookOrder +
            ", numberOfChapter=" + String(self.numberOfChapters)
        return str
    }
}
