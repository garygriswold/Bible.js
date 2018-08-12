//
//  SettingsAdapter.swift
//  Settings
//
//  Created by Gary Griswold on 8/8/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import Utility

class SettingsAdapter {
    
    private static let SETTINGS_DB = "Settings.db"
    private static let VERSIONS_DB = "Versions.db"
    private static let LANGS_SELECTED = "langs_selected"
    private static let BIBLE_SELECTED = "bible_selected"
    
    deinit {
        print("**** deinit SettingsAdapter ******")
    }
    
    //
    // Settings methods
    //
    
    func getLanguageSettings() -> [String] {
        if let langs = self.getSettings(name: SettingsAdapter.LANGS_SELECTED) {
            return langs
        } else {
            var isos = [String]()
            for loc in Locale.preferredLanguages { // Returns locale in String form
                let locale = Locale(identifier: loc)
                if let code = locale.languageCode {
                    isos.append(code)
                }
            }
            return isos
        }
    }
    
    func getBibleSettings() -> [String] {
        if let bibles = self.getSettings(name: SettingsAdapter.BIBLE_SELECTED) {
            return bibles
        } else {
            return [] // TBD
        }
    }
    
    func updateSettings(languages: [Language]) {
        var keys = [String]()
        for lang in languages {
            keys.append(lang.iso)
        }
        self.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: keys)
    }
    
    func updateSettings(bibles: [Bible]) {
        var keys = [String]()
        for bible in bibles {
            keys.append(bible.bibleId)
        }
        self.updateSettings(name: SettingsAdapter.BIBLE_SELECTED, settings: keys)
    }
    
    private func getSettings(name: String) -> [String]? {
        let sql = "SELECT value FROM Settings WHERE name = ?"
        do {
            let db: Sqlite3 = try self.getSettingsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [name])
            if resultSet.count > 0 && resultSet[0].count > 0 {
                let value = resultSet[0][0]!
                return value.components(separatedBy: ",")
            } else {
                return nil
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getSettings \(err)")
        }
        return []
    }
    
    private func updateSettings(name: String, settings: [String]) {
        let sql = "REPLACE INTO Settings (name, value) VALUES (?,?)"
        let values = [name, settings.joined(separator: ",")]
        do {
            let db: Sqlite3 = try self.getSettingsDB()
            let count = try db.executeV1(sql: sql, values: values)
            print("Settings updated \(count)")
        } catch let err {
            print("ERROR: SettingsAdapter.updateSettings \(err)")
        }
    }
    
    private func getSettingsDB() throws -> Sqlite3 {
        var db: Sqlite3?
        do {
            db = try Sqlite3.findDB(dbname: SettingsAdapter.SETTINGS_DB)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: SettingsAdapter.SETTINGS_DB, copyIfAbsent: false)
            // Caution, this create table comes from AppUpdate.js and must be consistent with it.
            let create = "CREATE TABLE IF NOT EXISTS Settings(name TEXT PRIMARY KEY NOT NULL, value TEXT NULL)"
            _ = try db?.executeV1(sql: create, values: [])
        }
        return db!
    }
    
    //
    // Language Versions.db methods
    
    func getLanguagesSelected(selected: [String]) -> [Language] {
        let sql =  "SELECT distinct iso1 FROM Language WHERE iso1" + genQuest(array: selected)
        let results = getLanguages(sql: sql, selected: selected)
        
        // Sort results by selected list
        var map = [String:Language]()
        for result in results {
            map[result.iso] = result
        }
        var languages = [Language]()
        for iso: String in selected {
            if let found: Language = map[iso] {
                languages.append(found)
            }
        }
        return languages
    }
    
    func getLanguagesAvailable(selected: [String]) -> [Language] {
        let sql =  "SELECT distinct iso1 FROM Language WHERE iso1 NOT" + genQuest(array: selected)
        return getLanguages(sql: sql, selected: selected)
    }
    
    private func getLanguages(sql: String, selected: [String]) -> [Language] {
        var languages = [Language]()
        do {
            let currLocale = Locale.current
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: selected)
            for row in resultSet {
                let iso: String = row[0]!
                let langLocale = Locale(identifier: iso)
                let name = langLocale.localizedString(forLanguageCode: iso)
                let localized = currLocale.localizedString(forLanguageCode: iso)
                if name != nil && localized != nil {
                    languages.append(Language(iso: iso, name: name!, localized: localized!))
                } else {
                    print("Dropped language \(iso) because localizedString failed.")
                }
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getLanguages \(err)")
        }
        return languages
    }
    
    //
    // Bible Versions.db methods
    //
    
    func getBiblesSelected(selectedLanguages: [String], selectedBibles: [String]) -> [Bible] {
        let sql =  "SELECT bibleId, abbr, iso3, name, vname FROM Bible WHERE bibleId" +
            genQuest(array: selectedBibles) + " AND iso3 IN (SELECT iso3 FROM Language WHERE iso1" +
            genQuest(array: selectedLanguages) + ")"
        let results = getBibles(sql: sql, selectedLanguages: selectedLanguages, selectedBibles: selectedBibles)
        
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
    
    func getBiblesAvailable(selectedLanguages: [String], selectedBibles: [String]) -> [Bible] {
        let sql =  "SELECT bibleId, abbr, iso3, name, vname FROM Bible WHERE bibleId NOT" +
            genQuest(array: selectedBibles) + " AND iso3 IN (SELECT iso3 FROM Language WHERE iso1" +
            genQuest(array: selectedLanguages) + ") ORDER BY abbr"
        return getBibles(sql: sql, selectedLanguages: selectedLanguages, selectedBibles: selectedBibles)
    }
    
    private func getBibles(sql: String, selectedLanguages: [String], selectedBibles: [String]) -> [Bible] {
        var bibles = [Bible]()
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let values = selectedBibles + selectedLanguages
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: values)
            for row in resultSet {
                let name = (row[4] != nil) ? row[4]! : row[3]!
                bibles.append(Bible(bibleId: row[0]!, abbr: row[1]!, iso3: row[2]!, name: name))
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getBibles \(err)")
        }
        return bibles
    }
    
    private func getVersionsDB() throws -> Sqlite3 {
        var db: Sqlite3?
        do {
            db = try Sqlite3.findDB(dbname: SettingsAdapter.VERSIONS_DB)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: SettingsAdapter.VERSIONS_DB, copyIfAbsent: true)
        }
        return db!
    }
    
    private func genQuest(array: [String]) -> String {
        let quest = [String](repeating: "?", count: array.count)
        return " IN (" + quest.joined(separator: ",") + ")"
    }
}
