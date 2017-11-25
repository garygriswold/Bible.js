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
                " AND v.versionCode = '" + versionCode + "'" +
                " ORDER BY collectionCode DESC, mediaType ASC"
                // collectionCode sequence O, N, C
                // mediaType sequence Drama, NonDrama
        do {
            try db.open(dbPath: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            try db.stringSelect(query: query, complete: { resultSet in
                print("LENGTH \(resultSet.count)")
                for row in resultSet {
                    let item = TOCAudioBible(database: db, mediaSource: "FCBH", dbRow: row)
                    print("\(item.toString())")
                    // Because of the sort sequence, the following logic prefers Drama over Non-Drama
                    // And prefers NT or OT collection over CT
                    if self.newTestament == nil && (item.collectionCode == "NT" || item.collectionCode == "CT") {
                        self.newTestament = item
                    }
                    if self.oldTestament == nil && (item.collectionCode == "OT" || item.collectionCode == "CT" ) {
                        self.oldTestament = item
                    }
                    // !!!!! I don't really know what collectionCode is for Complete, here it is shown as CT
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
        let s3Key = damid + "_" + sequence + "_" + bookId + "_" + chapter + "_verse.json"
        AwsS3Cache.shared.readData(s3Bucket: "audio-us-east-1-shortsands",
                   s3Key: s3Key,
                   expireInterval: 604800, // 1 week in seconds
                   getComplete: { data in
                    if let verses = data {
                        let result = self.parseJson(data: verses)
                        self.metaDataVerse = TOCAudioChapter(jsonObject: result)
                    } else {
                        self.metaDataVerse = nil
                    }
                    complete(self.metaDataVerse)
        })
    }
    
    private func parseJson(data: Data?) -> Any? {
        if let json = data {
            do {
                let result = try JSONSerialization.jsonObject(with: json, options: [])
                return result
            } catch let jsonError {
                print("Error parsing Meta Data json \(jsonError)")
                return nil
            }
        } else {
            print("Download Meta Data Error")
            return nil
        }
    }
}



