//
//  MetaDataItem.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

class TOCAudioBible {
    
    let mediaSource: String
    let damId: String
    let dbpLanguageCode: String
    let dbpVersionCode: String
    let collectionCode: String
    let mediaType: String
    var booksById: Dictionary<String, TOCAudioBook>
    var booksBySeq: Dictionary<Int, TOCAudioBook>

    init(database: Sqlite3, mediaSource: String, dbRow: [String?]) {
        self.booksById = Dictionary<String, TOCAudioBook>()
        self.booksBySeq = Dictionary<Int, TOCAudioBook>()
        self.mediaSource = mediaSource
        self.damId = dbRow[0]!
        self.collectionCode = dbRow[1]!
        self.mediaType = dbRow[2]!
        self.dbpLanguageCode = dbRow[3]!
        self.dbpVersionCode = dbRow[4]!

        let query = "SELECT bookId, bookOrder, numberOfChapters" +
            " FROM AudioBook" +
            " WHERE damId = ?"
        do {
            try database.queryV1(sql: query, values: [self.damId], complete: { resultSet in
                for row in resultSet {
                    let book = TOCAudioBook(bible: self, dbRow: row)
                    print("\(book.toString())")
                    self.booksById[book.bookId] = book
                    self.booksBySeq[book.sequence] = book
                }
            })
            
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
        }
    }
    
    deinit {
       print("***** Deinit TOCAudioBible *****") 
    }
    
    func nextChapter(reference: Reference) -> Reference? {
        let ref = reference
        if let book = self.booksById[ref.book] {
            if (ref.chapterNum < book.numberOfChapters) {
                let next = ref.chapterNum + 1
                let nextStr = String(next)
                switch(nextStr.count) {
                    case 1: return Reference(bible: ref.tocAudioBible, book: ref.tocAudioBook,
                                             chapter: "00" + nextStr, fileType: ref.fileType)
                    case 2: return Reference(bible: ref.tocAudioBible, book: ref.tocAudioBook,
                                             chapter: "0" + nextStr, fileType: ref.fileType)
                    default: return Reference(bible: ref.tocAudioBible, book: ref.tocAudioBook,
                                              chapter: nextStr, fileType: ref.fileType)
                }
            } else {
                if let nextBook = self.booksBySeq[reference.sequenceNum + 1] {
                    return Reference(bible: ref.tocAudioBible, book: nextBook, chapter: "001", fileType: ref.fileType)
                }
            }
        }
        return nil
    }
    
    func toString() -> String {
        let str = "damId=" + self.damId +
                "\n languageCode=" + self.dbpLanguageCode +
                "\n versionCode=" + self.dbpVersionCode +
                "\n mediaType=" + self.mediaType +
                "\n collectionCode=" + self.collectionCode
        return str
    }
}
