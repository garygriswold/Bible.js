//
//  AudioTOCBible.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
//#if USE_FRAMEWORK
import AWS
import Utility
//#endif


class AudioTOCBible {
    
    let textVersion: String
    let silLang: String
    let mediaSource: String
    var oldTestament: AudioTOCTestament?
    var newTestament: AudioTOCTestament?
    let database: Sqlite3
    
    init(versionCode: String, silLang: String) {
        self.textVersion = versionCode
        self.silLang = silLang
        self.mediaSource = "FCBH"
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
        print("***** Deinit AudioMetaDataReader *****")
    }

    // NOTE: I don't know why this is asynchronous.  It is only a database query.
    func read(complete: @escaping (_ oldTest:AudioTOCTestament?, _ newTest:AudioTOCTestament?) -> Void) {
        let query = "SELECT a.damId, a.collectionCode, a.mediaType, a.dbpLanguageCode, a.dbpVersionCode" +
                " FROM audio a, audioVersion v" +
                " WHERE a.dbpLanguageCode = v.dbpLanguageCode" +
                " AND a.dbpVersionCode = v.dbpVersionCode" +
                " AND v.versionCode = ?" +
                " ORDER BY mediaType ASC, collectionCode ASC"
                // mediaType sequence Drama, NonDrama
                // collectionCode sequence NT, ON, OT
        do {
            //try self.database.open(dbPath: "Versions.db", copyIfAbsent: true)
            //defer { self.database.close() }
            let resultSet = try self.database.queryV1(sql: query, values: [self.textVersion])
            print("LENGTH \(resultSet.count)")
            var oldTestRow: [String?]? = nil
            var newTestRow: [String?]? = nil
            for row in resultSet {
                // Because of the sort sequence, the following logic prefers Drama over Non-Drama
                // Because of the sequenc of IF's, it prefers OT and NT over ON
                let collectionCode = row[1]!
                if newTestRow == nil && collectionCode == "NT" {
                    newTestRow = row
                }
                if newTestRow == nil && collectionCode == "ON" {
                    newTestRow = row
                }
                if oldTestRow == nil && collectionCode == "OT" {
                    oldTestRow = row
                }
                if oldTestRow == nil && collectionCode == "ON" {
                    oldTestRow = row
                }
            }
            if let oldRow = oldTestRow {
                self.oldTestament = AudioTOCTestament(bible: self, database: self.database, dbRow: oldRow)
            }
            if let newRow = newTestRow {
                self.newTestament = AudioTOCTestament(bible: self, database: self.database, dbRow: newRow)
            }
            self.readBookNames()
            complete(self.oldTestament, self.newTestament)
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
            complete(nil, nil)
        }
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
    
    func readVerseAudio(damid: String, bookId: String, chapter: Int,
                        complete: @escaping (_ audioVerse: AudioTOCChapter?) -> Void) {
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
            complete(metaDataVerse)
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
            complete(nil)
        }
    }
    
    private func readBookNames() {
        let query = "SELECT code, heading FROM tableContents"
        do {
            let dbName = self.textVersion + ".db"
            let db = Sqlite3()
            try db.open(dbname: dbName, copyIfAbsent: true)
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
    
    /*
    * Deprecated. This was used to parse verse positions as a dictionary
    private func parseJsonDictionary(json: String) -> NSDictionary? {
        var result: NSDictionary? = nil
        if let data = json.data(using: .utf8) {
            do {
                result = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? NSDictionary
            } catch let jsonError {
                print("Error parsing Meta Data json \(jsonError)")
            }
        }
        return result
    }
    */
}

