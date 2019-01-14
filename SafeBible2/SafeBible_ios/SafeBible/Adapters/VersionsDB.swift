//
//  VersionsDB.swift
//  Settings
//
//  Created by Gary Griswold on 10/24/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct VersionsDB {
    
    static var shared = VersionsDB()
    
    private init() {}
    
    //
    // Bible
    //
    func getBible(bibleId: String) -> Bible {
        let sql = "SELECT bibleId, abbr, iso3, localizedName, textBucket, textId, keyTemplate,"
            + " audioBucket, otDamId, ntDamId FROM Bible WHERE bibleId = ?"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [bibleId])
            if resultSet.count > 0 && resultSet[0].count > 0 {
                let row = resultSet[0]
                return Bible(bibleId: row[0]!, abbr: row[1]!, iso3: row[2]!, name: row[3]!,
                             textBucket: row[4]!, textId: row[5]!, s3TextTemplate: row[6]!,
                             audioBucket: row[7], otDamId: row[8], ntDamId: row[9],
                             locale: Locale.current)
            }
        } catch let err {
            print("ERROR: VersionsDB.getBible \(err)")
        }
        // Return default, because optional causes too many complexities in program
        // Failure could occur when a bibleId in user history is removed.
        return Bible(bibleId: "ENGESV", abbr: "ESV", iso3: "eng", name: "English Standard",
                     textBucket: "dbp-prod", textId: "ENGESV", s3TextTemplate: "%I_%O_%B_%C.html",
                     audioBucket: nil, otDamId: nil, ntDamId: nil, locale: Locale.current)
    }
    
    //
    // Videos
    //
    func getJesusFilmLanguage(iso3: String, country: String?) -> String? {
        let cntry = (country != nil) ? country : "US"
        var sql = "SELECT languageId FROM JesusFilm WHERE country=? AND iso3=? ORDER BY population DESC"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            var resultSet: [[String?]] = try db.queryV1(sql: sql, values: [cntry, iso3])
            if resultSet.count > 0 {
                return resultSet[0][0]
            }
            sql = "SELECT languageId FROM JesusFilm WHERE iso3=? ORDER BY population DESC"
            resultSet = try db.queryV1(sql: sql, values: [iso3])
            if resultSet.count > 0 {
                return resultSet[0][0]
            }
        } catch let err {
            print("ERROR: VersionsDB.getJesusFilmLanguage \(err)")
        }
        return nil
    }
    
    func getVideos(iso3: String, languageId: String?) -> [Video] {
        let sql = "SELECT languageId, v.mediaId, mediaSource, title, lengthMS, HLS_URL,"
            + " description FROM Video v, VideoSeq s WHERE v.mediaId = s.mediaId"
            + " AND languageId IN (?,?) ORDER BY s.sequence"
        let langId = (languageId != nil) ? languageId : iso3
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [iso3, langId])
            if resultSet.count > 0 {
                let videos = resultSet.map {
                    Video(languageId: $0[0]!, mediaId: $0[1]!, mediaSource: $0[2]!, title: $0[3]!,
                          lengthMS: Int($0[4]!)!, HLS_URL: $0[5]!, description: $0[6])
                }
                return videos
            }
        } catch let err {
            print("ERROR: VersionsDB.getVideos \(err)")
        }
        return []
    }
    
    //
    // Common
    //
    private func getVersionsDB() throws -> Sqlite3 {
        var db: Sqlite3?
        let dbname = "Versions.db"
        do {
            db = try Sqlite3.findDB(dbname: dbname)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: dbname, copyIfAbsent: true)
        }
        return db!
    }
}

