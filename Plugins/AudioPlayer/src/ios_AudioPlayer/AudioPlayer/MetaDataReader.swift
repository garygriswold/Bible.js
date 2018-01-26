//
//  MetaDataReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import AWS

class MetaDataReader {
    
    var oldTestament: TOCAudioBible?
    var newTestament: TOCAudioBible?
    var metaDataVerse: TOCAudioChapter?
    
    init() {
        self.oldTestament = nil
        self.newTestament = nil
    }
    
    deinit {
        print("***** Deinit MetaDataReader *****")
    }

    func read(versionCode: String, complete: @escaping (_ oldTest:TOCAudioBible?, _ newTest:TOCAudioBible?) -> Void) {
        let db = Sqlite3()
        let query = "SELECT a.damId, a.collectionCode, a.mediaType, a.dbpLanguageCode, a.dbpVersionCode" +
                " FROM audio a, audioVersion v" +
                " WHERE a.dbpLanguageCode = v.dbpLanguageCode" +
                " AND a.dbpVersionCode = v.dbpVersionCode" +
                " AND v.versionCode = ?" +
                " ORDER BY mediaType ASC, collectionCode ASC"
                // mediaType sequence Drama, NonDrama
                // collectionCode sequence NT, ON, OT
        do {
            try db.open(dbPath: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            try db.queryV1(sql: query, values: [versionCode], complete: { resultSet in
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
                    self.oldTestament = TOCAudioBible(database: db, mediaSource: "FCBH", dbRow: oldRow)
                }
                if let newRow = newTestRow {
                    self.newTestament = TOCAudioBible(database: db, mediaSource: "FCBH", dbRow: newRow)
                }
                complete(self.oldTestament, self.newTestament)
            })
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
            complete(nil, nil)
        }
    }
    /**
    * This function will only return results after read has been called.
    */
    func findBook(bookId: String) -> TOCAudioBook? {
        var result: TOCAudioBook? = nil
        if self.oldTestament != nil {
            result = self.oldTestament!.booksById[bookId]
        }
        if self.newTestament != nil {
            result = self.newTestament!.booksById[bookId]
        }
        return result
    }
    
    func readVerseAudio(damid: String, sequence: String, bookId: String, chapter: String,
                        complete: @escaping (_ audioVerse: TOCAudioChapter?) -> Void) {
        self.metaDataVerse = nil
        let s3Bucket = damid.lowercased() + ".shortsands.com"
        let s3Key = "Verse_" + sequence + "_" + bookId + ".json"
        AwsS3Cache.shared.readData(s3Bucket: s3Bucket,
               s3Key: s3Key,
               expireInterval: 604800, // 1 week in seconds
               getComplete: { data in
                    if let verses = data {
                        let result = self.parseJsonDictionary(json: verses)
                        if let chapterNum = Int(chapter) {
                            let chapterStr = String(chapterNum)
                            if let dictionary = result?[chapterStr] as? NSDictionary {
                                self.metaDataVerse = TOCAudioChapter(chapterDictionary: dictionary)
                            } else {
                                print("ERROR: Chapter not found in verse meta data.")
                            }
                        } else {
                            print("ERROR: Chapter was invalid number.")
                        }
                    } else {
                        print("ERROR: There was no data retrieved.")
                    }
                    complete(self.metaDataVerse)
            })
    }
    
    private func parseJsonDictionary(json: Data) -> NSDictionary? {
        do {
            let result = try JSONSerialization.jsonObject(with: json, options:.allowFragments) as? NSDictionary
            return result
        } catch let jsonError {
            print("Error parsing Meta Data json \(jsonError)")
            return nil
        }
    }
}


