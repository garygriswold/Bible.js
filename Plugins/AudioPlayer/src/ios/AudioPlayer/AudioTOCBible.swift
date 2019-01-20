//
//  AudioTOCBible.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
import AWS
import Utility

class AudioTOCBible {
    
    let mediaSource: String
    let bibleId: String
    let iso3: String
    let audioBucket: String?
    let otDamId: String?
    let ntDamId: String?

    var oldTestament: AudioTOCTestament?
    var newTestament: AudioTOCTestament?
    private let database: Sqlite3
    
    init(source: String, bibleId: String, iso3: String,
         audioBucket: String?, otDamId: String?, ntDamId: String?) {
        self.mediaSource = source
        self.bibleId = bibleId
        self.iso3 = iso3
        self.audioBucket = audioBucket
        self.otDamId = otDamId
        self.ntDamId = ntDamId
        self.oldTestament = nil
        self.newTestament = nil
        self.database = Sqlite3()
        do {
            try self.database.open(dbname: "Versions.db", copyIfAbsent: true)
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
        }
    }
    
    deinit {
        print("***** Deinit AudioTOCBible *****")
    }
    
    func read() -> String {
        var bookIdList = ""
        if self.otDamId != nil {
            self.oldTestament = AudioTOCTestament(bible: self, database: self.database, damId: self.otDamId!)
            bookIdList = self.oldTestament!.getBookList()
        }
        if self.ntDamId != nil {
            self.newTestament = AudioTOCTestament(bible: self, database: self.database, damId: self.ntDamId!)
            if bookIdList.count > 0 {
                bookIdList += ","
            }
            bookIdList += self.newTestament!.getBookList()
        }
        self.readBookNames()
        return bookIdList
    }

    /**
    * This function will only return results after read has been called.
    */
    func findBook(bookId: String) -> AudioTOCBook? {
        var result: AudioTOCBook? = nil
        if let oldTest = self.oldTestament {
            result = oldTest.booksById[bookId]
        }
        if result == nil {
            if let newTest = self.newTestament {
                result = newTest.booksById[bookId]
            }
        }
        return result
    }
    
    func readVerseAudio(damid: String, bookId: String, chapter: Int) -> AudioTOCChapter? {
        var metaDataVerse: AudioTOCChapter? = nil
        let query = "SELECT versePositions FROM AudioChapter WHERE damId = ? AND bookId = ? AND chapter = ?"
        do {
            let resultSet = try self.database.queryV1(sql: query, values: [damid, bookId, String(chapter)])
            print("LENGTH \(resultSet.count)")
            if resultSet.count > 0 {
                let row = resultSet[0]
                if let verses = row[0] {
                    metaDataVerse = AudioTOCChapter(json: verses)
                }
            }
            return metaDataVerse
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
            return nil
        }
    }
    
    private func readBookNames() {
        let query = "SELECT bookId, name from TableContents"
        do {
            let dbName = self.bibleId + ".db"
            let db = Sqlite3()
            try db.open(dbname: dbName, copyIfAbsent: true)
            let resultSet = try db.queryV1(sql: query, values: [])
            for row in resultSet {
                let bookId = row[0]!
                if let oldTest = self.oldTestament?.booksById[bookId] {
                    oldTest.bookName = row[1]!
                } else if let newTest = self.newTestament?.booksById[bookId] {
                    newTest.bookName = row[1]!
                }
            }
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
        }
    }
}

