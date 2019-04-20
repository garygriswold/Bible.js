//
//  SettingsAdapter.swift
//  Settings
//
//  Created by Gary Griswold on 8/8/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Utility

struct SettingsAdapter {
    
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
            let db: Sqlite3 = try VersionsDB.shared.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: langScript )
            let languages = resultSet.map { Language(iso: $0[0]!, script: $0[1]!) }
            return languages
        } catch let err {
            print("ERROR: SettingsAdapter.getLanguages \(err)")
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
            let db: Sqlite3 = try VersionsDB.shared.getVersionsDB()
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
            print("ERROR: SettingsAdapter.getBibles \(err)")
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
            let db: Sqlite3 = try VersionsDB.shared.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [])
            let bibles = resultSet.map {
                Bible(bibleId: $0[0]!, abbr: $0[1]!, iso3: $0[2]!, name: $0[3]!,
                      textBucket: $0[4]!, textId: $0[5]!, s3TextTemplate: $0[6]!,
                      audioBucket: $0[7], otDamId: $0[8], ntDamId: $0[9],
                      iso: $0[10]!, script: $0[11]!)
            }
            return bibles
        } catch let err {
            print("ERROR: SettingsAdapter.getAllBibles \(err)")
        }
        return [Bible]()
    }
    
    func genQuest(array: [Any]) -> String {
        let quest = [String](repeating: "?", count: array.count)
        return " IN (" + quest.joined(separator: ",") + ")"
    }
}
