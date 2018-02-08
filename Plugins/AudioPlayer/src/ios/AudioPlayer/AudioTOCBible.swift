//
//  MetaDataItem.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

class AudioTOCBible {
    
    let textVersion: String
    let silLang: String
    let mediaSource: String
    let damId: String
    let dbpLanguageCode: String
    let dbpVersionCode: String
    let collectionCode: String
    let mediaType: String
    var booksById: Dictionary<String, AudioTOCBook>
    var booksBySeq: Dictionary<Int, AudioTOCBook>

    init(database: AudioSqlite3, textVersion: String, silLang: String, mediaSource: String, dbRow: [String?]) {
        self.booksById = Dictionary<String, AudioTOCBook>()
        self.booksBySeq = Dictionary<Int, AudioTOCBook>()
        self.textVersion = textVersion
        self.silLang = silLang
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
                    let book = AudioTOCBook(bible: self, dbRow: row)
                    print("\(book.toString())")
                    self.booksById[book.bookId] = book
                    self.booksBySeq[book.sequence] = book
                }
            })
            
        } catch let err {
            print("ERROR \(AudioSqlite3.errorDescription(error: err))")
        }
    }
    
    deinit {
       print("***** Deinit TOCAudioTOCBible *****") 
    }
    
    func nextChapter(reference: AudioReference) -> AudioReference? {
        let ref = reference
        let book = ref.tocAudioBook
        if (ref.chapterNum < book.numberOfChapters) {
            let next = ref.chapterNum + 1
            return AudioReference(bible: ref.tocAudioBible, book: ref.tocAudioBook, chapterNum: next, fileType: ref.fileType)
        } else {
            if let nextBook = self.booksBySeq[reference.sequenceNum + 1] {
                return AudioReference(bible: ref.tocAudioBible, book: nextBook, chapter: "001", fileType: ref.fileType)
            }
        }
        return nil
    }
    
    func priorChapter(reference: AudioReference) -> AudioReference? {
        let ref = reference
        let prior = ref.chapterNum - 1
        if (prior > 0) {
            return AudioReference(bible: ref.tocAudioBible, book: ref.tocAudioBook, chapterNum: prior, fileType: ref.fileType)
        } else {
            if let priorBook = self.booksBySeq[reference.sequenceNum - 1] {
                return AudioReference(bible: ref.tocAudioBible, book: priorBook,
                                 chapterNum: priorBook.numberOfChapters, fileType: ref.fileType)
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
