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
    // Language Versions.db methods
    //
    func getLanguagesSelected(selected: [Language]) -> [Language] {
        let sql =  "SELECT iso1, script FROM Language WHERE iso1 || script" + genQuest(array: selected)
        let results = getLanguages(sql: sql, selected: selected)
        
        var languages = [Language]()
        for loc in selected {
            if let index: Int = results.index(of: loc) {
                languages.append(results[index])
            }
        }
        return languages
    }
    
    func getLanguagesAvailable(selected: [Language]) -> [Language] {
        let sql =  "SELECT iso1, script FROM Language WHERE iso1 || script NOT" + genQuest(array: selected)
        let available = getLanguages(sql: sql, selected: selected)
        return available.sorted{ $0.localized < $1.localized }
    }
    
    private func getLanguages(sql: String, selected: [Language]) -> [Language] {
        let langScript = selected.map { $0.langScript }
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: langScript )
            let languages = resultSet.map { Language(iso: $0[0]!, script: $0[1]!) }
            return languages
        } catch let err {
            print("ERROR: VersionDB.shared.getLanguages \(err)")
        }
        return [Language]()
    }
    
    //
    // Bible Versions.db methods
    //
    func getBiblesSelected(locales: [Language], selectedBibles: [String]) -> [Bible] {
        var results = [Bible]()
        for locale in locales {
            let some = self.getBiblesSelected(locale: locale, selectedBibles: selectedBibles)
            results += some
        }
        // Sort results by selectedBibles list
        var map = [String:Bible]()
        for result in results {
            map[result.bibleId] = result
        }
        var bibles = [Bible]()
        for bibleId: String in selectedBibles {
            if let found: Bible = map[bibleId] {
                bibles.append(found)
            }
        }
        return bibles
    }
    
    private func getBiblesSelected(locale: Language, selectedBibles: [String]) -> [Bible] {
        let sql = "SELECT bibleId, abbr, iso3, localizedName, textBucket, textId, keyTemplate,"
            + " audioBucket, otDamId, ntDamId, iso1, script"
            + " FROM Bible"
            + " WHERE bibleId" + genQuest(array: selectedBibles)
            + " AND iso1 || script = ?"
            + " AND localizedName IS NOT null"
        return getBibles(sql: sql, locale: locale, selectedBibles: selectedBibles)
    }
    
    func getBiblesAvailable(locale: Language, selectedBibles: [String]) -> [Bible] {
        let sql = "SELECT bibleId, abbr, iso3, localizedName, textBucket, textId, keyTemplate,"
            + " audioBucket, otDamId, ntDamId, iso1, script"
            + " FROM Bible"
            + " WHERE bibleId NOT" + genQuest(array: selectedBibles)
            + " AND iso1 || script = ?"
            + " AND localizedName IS NOT null"
            + " ORDER BY localizedName"
        return getBibles(sql: sql, locale: locale, selectedBibles: selectedBibles)
    }
    
    private func getBibles(sql: String, locale: Language, selectedBibles: [String]) -> [Bible] {
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let values = selectedBibles + [locale.langScript]
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: values)
            let bibles = resultSet.map {
                Bible(bibleId: $0[0]!, abbr: $0[1]!, iso3: $0[2]!, name: $0[3]!,
                      textBucket: $0[4]!, textId: $0[5]!, s3TextTemplate: $0[6]!,
                      audioBucket: $0[7], otDamId: $0[8], ntDamId: $0[9],
                      iso: $0[10]!, script: $0[11]!)
            }
            return bibles
        } catch let err {
            print("ERROR: VersionsDb.shared.getBibles \(err)")
        }
        return [Bible]()
    }
    
    /**
     * Used by BibleInitialSelect.
     */
    func getAllBibles() -> [Bible] {
        let sql = "SELECT bibleId, abbr, iso3, localizedName, textBucket, textId, keyTemplate,"
            + " audioBucket, otDamId, ntDamId, iso1, script"
            + " FROM Bible"
            + " WHERE localizedName IS NOT NULL"
            + " AND textBucket IS NOT NULL"
            + " AND textId IS NOT NULL"
            + " AND versionPriority < 4"
            + " ORDER BY iso1, versionPriority"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [])
            let bibles = resultSet.map {
                Bible(bibleId: $0[0]!, abbr: $0[1]!, iso3: $0[2]!, name: $0[3]!,
                      textBucket: $0[4]!, textId: $0[5]!, s3TextTemplate: $0[6]!,
                      audioBucket: $0[7], otDamId: $0[8], ntDamId: $0[9],
                      iso: $0[10]!, script: $0[11]!)
            }
            return bibles
        } catch let err {
            print("ERROR: VersionsDB.shared.getAllBibles \(err)")
        }
        return [Bible]()
    }
    
    private func genQuest(array: [Any]) -> String {
        let quest = [String](repeating: "?", count: array.count)
        return " IN (" + quest.joined(separator: ",") + ")"
    }
    
    //
    // Bible
    //
    func getBible(bibleId: String) -> Bible {
        let sql = "SELECT bibleId, abbr, iso3, localizedName, textBucket, textId, keyTemplate,"
            + " audioBucket, otDamId, ntDamId, iso1, script FROM Bible WHERE bibleId = ?"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [bibleId])
            if resultSet.count > 0 && resultSet[0].count > 0 {
                let row = resultSet[0]
                return Bible(bibleId: row[0]!, abbr: row[1]!, iso3: row[2]!, name: row[3]!,
                             textBucket: row[4]!, textId: row[5]!, s3TextTemplate: row[6]!,
                             audioBucket: row[7], otDamId: row[8], ntDamId: row[9],
                             iso: row[10]!, script: row[11]!)
            }
        } catch let err {
            print("ERROR: VersionsDB.getBible \(err)")
        }
        // Return default, because optional causes too many complexities in program
        // Failure could occur when a bibleId in user history is removed.
        return Bible(bibleId: "ENGESV.db", abbr: "ESV", iso3: "eng", name: "English Standard",
                     textBucket: "text-us-east-1-shortsands", textId: "text/ENGESV/ENGESV",
                     s3TextTemplate: "%I_%O_%B_%C.html",
                     audioBucket: nil, otDamId: nil, ntDamId: nil, iso: "en", script: "")
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
        return try Sqlite3.openDB(dbname: "Versions.db", copyIfAbsent: true)
    }
}

