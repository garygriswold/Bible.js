//
//  SettingsDB.swift
//  Settings
//
//  Created by Gary Griswold on 10/20/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct SettingsDB {
    
    static var shared = SettingsDB()
    
    private static let MAX_HISTORY: Int = 200
    private static let MAX_CONCORDANCE_HIST: Int = 20 // 30
    
    // Changing these static values would break data stored in User settings
    private static let LANGS_SELECTED = "langs_selected"
    private static let BIBLE_SELECTED = "bible_selected"
    private static let PSEUDO_USER_ID = "pseudo_user_id"
    private static let CURR_VERSION = "version" // I think this is unused.  History is used instead.
    private static let USER_FONT_DELTA = "userFontDelta"
    private static let CONCORDANCE_HIST = "concordance_hist"
    
    private init() {}
    
    //
    // Settings methods
    //
    func getLanguageSettings() -> [Language] {
        var languages: [String]
        if let langs = self.getSettings(name: SettingsDB.LANGS_SELECTED) {
            languages = langs
        } else {
            languages = Locale.preferredLanguages
            SettingsDB.shared.updateSettings(name: SettingsDB.LANGS_SELECTED, settings: languages)
        }
        let locales: [Language] = languages.map { Language(identifier: $0) }
        return locales
    }
    
    func getBibleSettings() -> [String] {
        if let bibles = self.getSettings(name: SettingsDB.BIBLE_SELECTED) {
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
                self.updateSettings(name: SettingsDB.LANGS_SELECTED, settings: localeStrs)
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
        SettingsDB.shared.updateSettings(name: SettingsDB.BIBLE_SELECTED, settings: currBibles)
    }
    
    func updateSettings(languages: [Language]) {
        let locales = languages.map { $0.fullIdentifier }
        SettingsDB.shared.updateSettings(name: SettingsDB.LANGS_SELECTED, settings: locales)
    }
    
    func updateSettings(bibles: [Bible]) {
        let keys = bibles.map { $0.bibleId }
        self.updateSettings(name: SettingsDB.BIBLE_SELECTED, settings: keys)
        if let first = keys.first {
            self.updateSetting(name: SettingsDB.CURR_VERSION, setting: first)
        }
    }
    
    func getPseudoUserId() -> String {
        var userId: String? = self.getSetting(name: SettingsDB.PSEUDO_USER_ID)
        if userId == nil {
            userId = UUID().uuidString // Generates a pseudo random GUID
            SettingsDB.shared.updateSetting(name: SettingsDB.PSEUDO_USER_ID, setting: userId!)
        }
        return userId!
    }
    
    func getUserFontDelta() -> CGFloat {
        if let deltaStr = self.getSetting(name: SettingsDB.USER_FONT_DELTA) {
            if let deltaDbl = Double(deltaStr) {
                return CGFloat(deltaDbl)
            }
        }
        return 1.0
    }
    
    func setUserFontDelta(fontDelta: CGFloat) {
        let deltatDbl = Double(fontDelta)
        self.updateSetting(name: SettingsDB.USER_FONT_DELTA, setting: String(deltatDbl))
    }
    
    func getConcordanceHistory() -> [String] {
        let value = self.getSetting(name: SettingsDB.CONCORDANCE_HIST)
        if value != nil && value!.count > 0 {
            return value!.components(separatedBy: "|")
        } else {
            return [String]()
        }
    }
    
    func setConcordanceHistory(history: [String]) {
        var searches = history
        if searches.count > SettingsDB.MAX_CONCORDANCE_HIST {
            searches.removeFirst(searches.count - SettingsDB.MAX_CONCORDANCE_HIST)
        }
        self.updateSetting(name: SettingsDB.CONCORDANCE_HIST, setting: searches.joined(separator: "|"))
    }
    
    //
    // Settings Table General Methods
    //
    func getSettings(name: String) -> [String]? {
        let value = self.getSetting(name: name)
        if value != nil && value!.count > 0 {
            return value!.components(separatedBy: ",")
        } else {
            return nil
        }
    }
    
    func getFloat(name: String, ifNone: Float) -> Float {
        if let value = self.getSetting(name: name) {
            if let float = Float(value) {
                return float
            }
        }
        return ifNone
    }
    
    func getBool(name: String, ifNone: Bool) -> Bool {
        if let value = self.getSetting(name: name) {
            return (value == "T") ? true : false
        }
        return ifNone
    }

    func getSetting(name: String) -> String? {
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
            print("ERROR: SettingsDB.getSettings \(err)")
        }
        return nil
    }
    
    func updateSettings(name: String, settings: [String]) {
        self.updateSetting(name: name, setting: settings.joined(separator: ","))
    }
    
    func updateFloat(name: String, setting: Float) {
        self.updateSetting(name: name, setting: "\(setting)")
    }
    
    func updateBool(name: String, setting: Bool) {
        self.updateSetting(name: name, setting: (setting) ? "T" : "F")
    }
    
    func updateSetting(name: String, setting: String) {
        let sql = "REPLACE INTO Settings (name, value) VALUES (?,?)"
        let values = [name, setting]
        do {
            let db: Sqlite3 = try self.getSettingsDB()
            let count = try db.executeV1(sql: sql, values: values)
            print("Setting updated \(count)")
        } catch let err {
            print("ERROR: SettingsDB.updateSetting \(err)")
        }
    }
    
    //
    // History Table
    //
    func getHistory() -> [History] {
        let db: Sqlite3
        do {
            db = try self.getSettingsDB()
            // Note that verse is being ignored here
            let sql = "SELECT datetime, bibleId, bookId, chapter, verse" +
                    " FROM History2 ORDER BY datetime ASC"
            let resultSet = try db.queryV1(sql: sql, values: [])
            let history = resultSet.map {
                History(reference: Reference(bibleId: $0[1]!, bookId: $0[2]!, chapter: Int($0[3]!) ?? 0),
                        datetime: CFAbsoluteTime($0[0]!)!)
            }
            return history
        } catch {
            return []
        }
    }
    
    func storeHistory(history: History) {
        let db: Sqlite3
        do {
            db = try self.getSettingsDB()
            let sql = "REPLACE INTO History2 (datetime, bibleId, bookId, chapter, verse)" +
                    " VALUES (?,?,?,?,?)"
            let ref = history.reference
            let values: [Any?] = [history.datetime, ref.bibleId, ref.bookId, ref.chapter, nil]
            _ = try db.executeV1(sql: sql, values: values)
        } catch let err {
            print("ERROR SettingsDB.storeHistory \(err)")
        }
    }
    
    func clearHistory() {
        DispatchQueue.main.async(execute: {
            let db: Sqlite3
            do {
                db = try self.getSettingsDB()
                let sql = "DELETE FROM History2"
                _ = try db.executeV1(sql: sql, values: [])
            } catch let err {
                print("ERROR SettingsDB.clearHistory \(err)")
            }
        })
    }
    
    func cleanUpHistory() {
        DispatchQueue.main.async(execute: {
            let total = HistoryModel.shared.historyCount
            if total > SettingsDB.MAX_HISTORY {
                if let history = HistoryModel.shared.getHistoryItem(row: (total - SettingsDB.MAX_HISTORY)) {
                    let db: Sqlite3
                    do {
                        db = try self.getSettingsDB()
                        let sql = "DELETE FROM History2 WHERE datetime < ?"
                        _ = try db.executeV1(sql: sql, values: [history.datetime])
                    } catch let err {
                        print("ERROR SettingsDB.cleanUpHistory \(err)")
                    }
                }
            }
        })
    }

    private func getSettingsDB() throws -> Sqlite3 {
        var db: Sqlite3?
        let dbname = "Settings.db"
        do {
            db = try Sqlite3.findDB(dbname: dbname)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: dbname, copyIfAbsent: false)
            let create1 = "CREATE TABLE IF NOT EXISTS Settings("
                + " name TEXT PRIMARY KEY NOT NULL, value TEXT NULL)"
            _ = try db?.executeV1(sql: create1, values: [])
            let create2 = "CREATE TABLE IF NOT EXISTS History2("
                + " datetime REAL NOT NULL PRIMARY KEY,"
                + " bibleId TEXT NOT NULL,"
                + " bookId TEXT NOT NULL,"
                + " chapter INT NOT NULL,"
                + " verse INT NULL)"
            _ = try db?.executeV1(sql: create2, values: [])
        }
        return db!
    }
}
