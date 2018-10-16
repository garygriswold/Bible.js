//
//  SettingsAdapter.swift
//  Settings
//
//  Created by Gary Griswold on 8/8/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Utility

struct SettingsAdapter {
    
    // Changing these static values would break data stored in User settings
    private static let SETTINGS_DB = "Settings.db"
    private static let VERSIONS_DB = "Versions.db"
    private static let LANGS_SELECTED = "langs_selected"
    private static let BIBLE_SELECTED = "bible_selected"
    private static let PSEUDO_USER_ID = "pseudo_user_id"
    private static let CURR_VERSION = "version"
    private static let USER_FONT_DELTA = "userFontDelta"
    
    //
    // Settings methods
    //
    
    func getLanguageSettings() -> [Locale] {
        var languages: [String]
        if let langs = self.getSettings(name: SettingsAdapter.LANGS_SELECTED) {
            languages = langs
        } else {
            languages = Locale.preferredLanguages
            self.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: languages)
        }
        let locales: [Locale] = languages.map { Locale(identifier: $0) }
        return locales
    }
    
    func getBibleSettings() -> [String] {
        if let bibles = self.getSettings(name: SettingsAdapter.BIBLE_SELECTED) {
            return bibles
        } else {
            return [] // Returning empty causes BibleInitialSelect to be used.
        }
    }
 
//    func addLanguage(language: Language) {
//        let locales = self.getLanguageSettings()
//        var localeStrs = locales.map { $0.identifier }
//        let newLocale = language.locale
//        if !locales.contains(newLocale) {
//            localeStrs.append(newLocale.identifier)
//        }
//        self.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: localeStrs)
//    }

    func addBibles(bibles: [Bible]) {
        var currBibles = self.getBibleSettings()
        for bible in bibles {
            let bibleId = bible.bibleId
            if !currBibles.contains(bibleId) {
                currBibles.append(bibleId)
            }
        }
        self.updateSettings(name: SettingsAdapter.BIBLE_SELECTED, settings: currBibles)
    }
    
    func updateSettings(languages: [Language]) {
        let locales = languages.map { $0.locale.identifier }
        self.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: locales)
    }
    
    func updateSettings(bibles: [Bible]) {
        let keys = bibles.map { $0.bibleId }
        self.updateSettings(name: SettingsAdapter.BIBLE_SELECTED, settings: keys)
        if let first = keys.first {
            self.updateSetting(name: SettingsAdapter.CURR_VERSION, setting: first)
        }
    }
    
    func getPseudoUserId() -> String {
        var userId: String? = self.getSetting(name: SettingsAdapter.PSEUDO_USER_ID)
        if userId == nil {
            userId = UUID().uuidString // Generates a pseudo random GUID
            self.updateSetting(name: SettingsAdapter.PSEUDO_USER_ID, setting: userId!)
        }
        return userId!
    }
    
    func getUserFontDelta() -> CGFloat {
        if let deltaStr = self.getSetting(name: SettingsAdapter.USER_FONT_DELTA) {
            if let deltaDbl = Double(deltaStr) {
                return CGFloat(deltaDbl)
            }
        }
        return 1.0
    }
    
    func setUserFontDelta(fontDelta: CGFloat) {
        let deltatDbl = Double(fontDelta)
        self.updateSetting(name: SettingsAdapter.USER_FONT_DELTA, setting: String(deltatDbl))
    }
    
    private func getSettings(name: String) -> [String]? {
        if let value = self.getSetting(name: name) {
            return value.components(separatedBy: ",")
        } else {
            return nil
        }
    }
    
    private func getSetting(name: String) -> String? {
        let sql = "SELECT value FROM Settings WHERE name = ?"
        do {
            let db: Sqlite3 = try self.getSettingsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [name])
            if resultSet.count > 0 && resultSet[0].count > 0 {
                return resultSet[0][0]!
            } else {
                return nil
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getSettings \(err)")
        }
        return ""
    }
    
    private func updateSettings(name: String, settings: [String]) {
        self.updateSetting(name: name, setting: settings.joined(separator: ","))
    }
    
    private func updateSetting(name: String, setting: String) {
        let sql = "REPLACE INTO Settings (name, value) VALUES (?,?)"
        let values = [name, setting]
        do {
            let db: Sqlite3 = try self.getSettingsDB()
            let count = try db.executeV1(sql: sql, values: values)
            print("Setting updated \(count)")
        } catch let err {
            print("ERROR: SettingsAdapter.updateSetting \(err)")
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
    
    func getLanguagesSelected(selected: [Locale]) -> [Language] {
        let sql =  "SELECT distinct iso1 FROM Language WHERE iso1" + genQuest(array: selected)
        let results = getLanguages(sql: sql, selected: selected)
        
        // Sort results by selected list
        var map = [String:Language]()
        for result in results {
            map[result.iso] = result
        }
        var languages = [Language]()
        for loc: Locale in selected {
            if var found: Language = map[loc.languageCode ?? "??"] {
                found.locale = loc
                languages.append(found)
            }
        }
        return languages
    }
    
    func getLanguagesAvailable(selected: [Locale]) -> [Language] {
        let sql =  "SELECT distinct iso1 FROM Language WHERE iso1 NOT" + genQuest(array: selected)
        let available = getLanguages(sql: sql, selected: selected)
        return available.sorted{ $0.localized < $1.localized }
    }
    
    private func getLanguages(sql: String, selected: [Locale]) -> [Language] {
        var languages = [Language]()
        do {
            let isos: [String] = selected.map { $0.languageCode ?? "??" }
            let currLocale = Locale.current
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: isos)
            for row in resultSet {
                let iso: String = row[0]!
                let locale = Locale(identifier: iso)
                let name = locale.localizedString(forLanguageCode: iso)
                let localized = currLocale.localizedString(forLanguageCode: iso)
                if name != nil && localized != nil {
                    languages.append(Language(iso: iso, locale: locale, name: name!, localized: localized!))
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
    func getBiblesSelected(locales: [Locale], selectedBibles: [String]) -> [Bible] {
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
    
    private func getBiblesSelected(locale: Locale, selectedBibles: [String]) -> [Bible] {
        let sql = "SELECT bibleId, abbr, b.iso3, b.localizedName" +
            " FROM Bible b, Language l WHERE b.iso3 = l.iso3" +
            " AND b.bibleId" + genQuest(array: selectedBibles) +
            " AND l.iso1 = ?" +
            " AND b.localizedName IS NOT null"
        return getBibles(sql: sql, locale: locale, selectedBibles: selectedBibles)
    }
    
    func getBiblesAvailable(locale: Locale, selectedBibles: [String]) -> [Bible] {
        let sql = "SELECT bibleId, abbr, b.iso3, b.localizedName" +
            " FROM Bible b, Language l WHERE b.iso3 = l.iso3" +
            " AND b.bibleId NOT" + genQuest(array: selectedBibles) +
            " AND l.iso1 = ?" +
            " AND b.localizedName IS NOT null" +
            " ORDER BY b.localizedName"
        return getBibles(sql: sql, locale: locale, selectedBibles: selectedBibles)
    }
    
    private func getBibles(sql: String, locale: Locale, selectedBibles: [String]) -> [Bible] {
        var bibles = [Bible]()
        let iso: String = locale.languageCode ?? "??"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let values = selectedBibles + [iso]
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: values)
            bibles = resultSet.map {
                Bible(bibleId: $0[0]!, abbr: $0[1]!, iso3: $0[2]!, name: $0[3]!, locale: locale)
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getBibles \(err)")
        }
        return bibles
    }
    
    /**
     * Deprecated: 8/30/18.  This method is only used by BibleInitialSelectExperiment.
    */
    func getAllBibles() -> [BibleDetail] {
        var bibles = [BibleDetail]()
        let sql = "SELECT bibleId, b.iso3, l.iso1, b.script, b.country FROM Bible b, Language l WHERE b.iso3 = l.iso3"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [])
            bibles = resultSet.map {
                BibleDetail(bibleId: $0[0]!, iso3: $0[1]!, iso1: $0[2], script: $0[3], country: $0[4])
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getAllBibles \(err)")
        }
        return bibles
    }
    
    func getVersionsDB() throws -> Sqlite3 {
        var db: Sqlite3?
        do {
            db = try Sqlite3.findDB(dbname: SettingsAdapter.VERSIONS_DB)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: SettingsAdapter.VERSIONS_DB, copyIfAbsent: true)
        }
        return db!
    }
    
    func genQuest(array: [Any]) -> String {
        let quest = [String](repeating: "?", count: array.count)
        return " IN (" + quest.joined(separator: ",") + ")"
    }
}
