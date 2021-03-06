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
    
    let bibleId: String
    let bibleName: String
    let iso3: String
    let audioBucket: String?
    let otDamId: String?
    let ntDamId: String?

    var oldTestament: AudioTOCTestament?
    var newTestament: AudioTOCTestament?
    private let database: Sqlite3
    
    init(bibleId: String, bibleName: String, iso3: String,
         audioBucket: String?, otDamId: String?, ntDamId: String?) {
        self.bibleId = bibleId
        self.bibleName = bibleName
        self.iso3 = iso3
        self.audioBucket = audioBucket
        self.otDamId = otDamId
        self.ntDamId = ntDamId
        self.oldTestament = nil
        self.newTestament = nil
        do {
            self.database = try Sqlite3.openDB(dbname: "Versions.db", copyIfAbsent: true)
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
            self.database = Sqlite3() // included so that database can have let
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
    
    /** This is opended and close separately, because Audio is a different thread */
    private func readBookNames() {
        let query = "SELECT code, name from TableContents"
        do {
            let db = Sqlite3()
            try db.open(dbname: self.bibleId, copyIfAbsent: true)
            defer { db.close() }
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

