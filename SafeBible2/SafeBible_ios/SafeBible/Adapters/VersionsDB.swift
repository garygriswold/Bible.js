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
                             audioBucket: row[7]!, otDamId: row[8]!, ntDamId: row[9]!,
                             locale: Locale.current)
            }
        } catch let err {
            print("ERROR: SettingsDB.getSettings \(err)")
        }
        // Return default, because optional causes too many complexities in program
        // Failure could occur when a bibleId in user history is removed.
        return Bible(bibleId: "ENGESV", abbr: "ESV", iso3: "eng", name: "English Standard",
                     textBucket: "dbp-prod", textId: "ENGESV", s3TextTemplate: "%I_%O_%B_%C.html",
                     audioBucket: nil, otDamId: nil, ntDamId: nil, locale: Locale.current)
    }
    
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

