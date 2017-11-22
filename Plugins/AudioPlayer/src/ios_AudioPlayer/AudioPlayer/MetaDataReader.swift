//
//  MetaDataReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import AWS

class MetaDataReader {
    
    var metaData: Dictionary<String, TOCAudioBible>
    var metaDataVerse: TOCAudioChapter?
    
    init() {
        self.metaData = Dictionary<String, TOCAudioBible>()
    }
    
    deinit {
        print("***** Deinit MetaDataReader *****")
    }
    /*
    func read(languageCode: String, mediaType: String,
              readComplete: @escaping (_ metaData: Dictionary<String, TOCAudioBible>) -> Void) {
        AwsS3Cache.shared.readData(s3Bucket: "audio-us-west-2-shortsands",
                   s3Key: languageCode + "_" + mediaType + ".json",
                   expireInterval: 604800, // 1 week in seconds
                   getComplete: { data in
            let result = self.parseJson(data: data)
            if (result is Array<AnyObject>) {
                let array: Array<AnyObject> = result as! Array<AnyObject>
                for item in array {
                    let metaItem = TOCAudioBible(mediaSource: "FCBH", jsonObject: item)
                    print("\(metaItem.toString())")
                    self.metaData[metaItem.damId] = metaItem
                }
            } else {
                print("Could not determine type of outer object in Meta Data")
            }
            readComplete(self.metaData)
        })
    }
    */
    func read(versionCode: String, complete: @escaping (_ metaData: Dictionary<String, TOCAudioBible>) -> Void) {
        let db = Sqlite3()
        let query = "SELECT a.damId, a.collectionCode, a.mediaType, a.dbpLanguageCode, a.dbpVersionCode" +
                " FROM audio a, audioVersion v" +
                " WHERE a.dbpLanguageCode = v.dbpLanguageCode" +
                " AND a.dbpVersionCode = v.dbpVersionCode" +
                " AND v.versionCode = '" + versionCode + "'"
        do {
            try db.open(dbPath: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            try db.stringSelect(query: query, complete: { resultSet in
                for row in resultSet {
                    let metaItem = TOCAudioBible(database: db, mediaSource: "FCBH", dbRow: row)
                    print("\(metaItem.toString())")
                    self.metaData[metaItem.damId] = metaItem
                }
                complete(self.metaData)
            })
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
            complete(self.metaData)
        }
    }
    
    func readVerseAudio(damid: String, sequence: String, bookId: String, chapter: String,
                        complete: @escaping (_ audioVerse: TOCAudioChapter?) -> Void) {
        let s3Key = damid + "_" + sequence + "_" + bookId + "_" + chapter + "_verse.json"
        AwsS3Cache.shared.readData(s3Bucket: "audio-us-east-1-shortsands",
                   s3Key: s3Key,
                   expireInterval: 604800, // 1 week in seconds
                   getComplete: { data in
            let result = self.parseJson(data: data)
            self.metaDataVerse = TOCAudioChapter(jsonObject: result)
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



