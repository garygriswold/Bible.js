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
    private static let LANGS_SELECTED = "langs_selected"
    private static let BIBLE_SELECTED = "bible_selected"
    private static let PSEUDO_USER_ID = "pseudo_user_id"
    private static let CURR_VERSION = "version" // I think this is unused.  History is used instead.
    private static let USER_FONT_DELTA = "userFontDelta"
    
    //
    // Settings methods
    //
    func getLanguageSettings() -> [Language] {
        var languages: [String]
        if let langs = SettingsDB.shared.getSettings(name: SettingsAdapter.LANGS_SELECTED) {
            languages = langs
        } else {
            languages = Locale.preferredLanguages
            SettingsDB.shared.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: languages)
        }
        let locales: [Language] = languages.map { Language(identifier: $0) }
        return locales
    }
    
    func getBibleSettings() -> [String] {
        if let bibles = SettingsDB.shared.getSettings(name: SettingsAdapter.BIBLE_SELECTED) {
            return bibles
        } else {
            return [] // Returning empty causes BibleInitialSelect to be used.
        }
    }
 
    func ensureLanguageAdded(language: Language?) {
        if (language != nil) {
            var locales = self.getLanguageSettings()
            if !locales.contains(language!) {
                locales.append(language!)
                let localeStrs = locales.map { $0.fullIdentifier }
                SettingsDB.shared.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: localeStrs)
            }
        }
    }

    func addBibles(bibles: [Bible]) {
        var currBibles = self.getBibleSettings()
        for bible in bibles {
            let bibleId = bible.bibleId
            if !currBibles.contains(bibleId) {
                currBibles.append(bibleId)
            }
        }
        SettingsDB.shared.updateSettings(name: SettingsAdapter.BIBLE_SELECTED, settings: currBibles)
    }
    
    func updateSettings(languages: [Language]) {
        let locales = languages.map { $0.fullIdentifier }
        SettingsDB.shared.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: locales)
    }
    
    func updateSettings(bibles: [Bible]) {
        let keys = bibles.map { $0.bibleId }
        SettingsDB.shared.updateSettings(name: SettingsAdapter.BIBLE_SELECTED, settings: keys)
        if let first = keys.first {
            SettingsDB.shared.updateSetting(name: SettingsAdapter.CURR_VERSION, setting: first)
        }
    }
    
    func getPseudoUserId() -> String {
        var userId: String? = SettingsDB.shared.getSetting(name: SettingsAdapter.PSEUDO_USER_ID)
        if userId == nil {
            userId = UUID().uuidString // Generates a pseudo random GUID
            SettingsDB.shared.updateSetting(name: SettingsAdapter.PSEUDO_USER_ID, setting: userId!)
        }
        return userId!
    }
    
    func getUserFontDelta() -> CGFloat {
        if let deltaStr = SettingsDB.shared.getSetting(name: SettingsAdapter.USER_FONT_DELTA) {
            if let deltaDbl = Double(deltaStr) {
                return CGFloat(deltaDbl)
            }
        }
        return 1.0
    }
    
    func setUserFontDelta(fontDelta: CGFloat) {
        let deltatDbl = Double(fontDelta)
        SettingsDB.shared.updateSetting(name: SettingsAdapter.USER_FONT_DELTA, setting: String(deltatDbl))
    }
    
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
