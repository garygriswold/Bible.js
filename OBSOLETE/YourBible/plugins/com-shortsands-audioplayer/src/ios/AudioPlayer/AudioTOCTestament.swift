//
//  AudioTOCTestament.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
#if USE_FRAMEWORK
import Utility
#endif

class AudioTOCTestament {
    
    let bible: AudioTOCBible
    let damId: String
    let dbpLanguageCode: String
    let dbpVersionCode: String
    let collectionCode: String
    let mediaType: String
    var booksById: Dictionary<String, AudioTOCBook>
    var booksBySeq: Dictionary<Int, AudioTOCBook>

    init(bible: AudioTOCBible, database: Sqlite3, dbRow: [String?]) {
        self.bible = bible
        self.booksById = Dictionary<String, AudioTOCBook>()
        self.booksBySeq = Dictionary<Int, AudioTOCBook>()
        self.damId = dbRow[0]!
        self.collectionCode = dbRow[1]!
        self.mediaType = dbRow[2]!
        self.dbpLanguageCode = dbRow[3]!
        self.dbpVersionCode = dbRow[4]!

        let query = "SELECT bookId, bookOrder, numberOfChapters" +
            " FROM AudioBook" +
            " WHERE damId = ?" +
            " ORDER BY bookOrder"
        do {
            let resultSet = try database.queryV1(sql: query, values: [self.damId])
            for row in resultSet {
                let book = AudioTOCBook(testament: self, dbRow: row)
                self.booksById[book.bookId] = book
                self.booksBySeq[book.sequence] = book
            }
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
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
            return AudioReference(book: ref.tocAudioBook, chapterNum: next, fileType: ref.fileType)
        } else {
            if let nextBook = self.booksBySeq[reference.sequenceNum + 1] {
                return AudioReference(book: nextBook, chapter: "001", fileType: ref.fileType)
            }
        }
        return nil
    }
    
    func priorChapter(reference: AudioReference) -> AudioReference? {
        let ref = reference
        let prior = ref.chapterNum - 1
        if (prior > 0) {
            return AudioReference(book: ref.tocAudioBook, chapterNum: prior, fileType: ref.fileType)
        } else {
            if let priorBook = self.booksBySeq[reference.sequenceNum - 1] {
                return AudioReference(book: priorBook,
                                 chapterNum: priorBook.numberOfChapters, fileType: ref.fileType)
            }
        }
        return nil
    }
    
    func getBookList() -> String {
        var array = [String]()
        for (_, book) in self.booksBySeq {
            array.append(book.bookId)
        }
        return array.joined(separator: ",")
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
