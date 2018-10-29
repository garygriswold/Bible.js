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
        let sql = "SELECT bibleId, abbr, iso3, localizedName, s3KeyPrefix, s3Key" +
                " FROM Bible WHERE bibleId = ?"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [bibleId])
            if resultSet.count > 0 && resultSet[0].count > 0 {
                let row = resultSet[0]
                return Bible(bibleId: row[0]!, abbr: row[1]!, iso3: row[2]!, name: row[3]!,
                             s3KeyPrefix: row[4]!, s3Key: row[5]!, locale: Locale.current)
            }
        } catch let err {
            print("ERROR: SettingsDB.getSettings \(err)")
        }
        // Return default, because optional causes too many complexities in program
        // Failure could occur when a bibleId in user history is removed.
        return Bible(bibleId: "ENGESV", abbr: "ESV", iso3: "eng", name: "English Standard",
                     s3KeyPrefix: "text/ENGESV/ENGESV/",
                     s3Key: "%I_%O_%B_%C.html", locale: Locale.current)
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

