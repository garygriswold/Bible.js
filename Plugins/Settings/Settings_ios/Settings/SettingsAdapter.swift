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
    
    private static var LANGS_SELECTED = "LANGS_SELECTED"
    private static var BIBLE_SELECTED = "BIBLE_SELECTED"
    
    //
    // Settings methods
    //
    
    func getLanguageSettings() -> [String] {
        let settings = "eng,deu,fra"
        return settings.components(separatedBy: ",")
        //return self.getSettings(name: SettingsAdapter.LANGS_SELECTED)
    }
    
    func getBibleSettings() -> [String] {
        let settings = "ENGKJV,ENGNIV,ENGESV"
        return settings.components(separatedBy: ",")
        //return self.getSettings(name: SettingsAdapter.BIBLE_SELECTED)
    }
    
    func updateLanguageSettings(languages: [String]) {
        self.updateSettings(name: SettingsAdapter.LANGS_SELECTED, settings: languages)
    }
    
    func updateBibleSettings(bibles: [String]) {
        self.updateSettings(name: SettingsAdapter.BIBLE_SELECTED, settings: bibles)
    }
    
    private func getSettings(name: String) -> [String] {
        let sql = "SELECT value FROM Settings WHERE name = ?"
        do {
            let db: Sqlite3 = try Sqlite3.findDB(dbname: "Settings.db")
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [name])
            if resultSet.count > 0 && resultSet[0].count > 0 {
                let value = resultSet[0][0]!
                return value.components(separatedBy: ",")
            } else {
                // must do default here and save result
                // In the meantime
                let settings = "eng,fra,deu"
                return settings.components(separatedBy: ",")
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getSettings \(err)")
        }
        return []
    }
    
    private func updateSettings(name: String, settings: [String]) {
        let sql = "UPDATE Settings SET value = ? WHERE name = ?"
        let values = [settings.joined(separator: ","), name]
        do {
            let db: Sqlite3 = try Sqlite3.findDB(dbname: "Settings.db")
            let count = try db.executeV1(sql: sql, values: values)
            print("Settings updated \(count)")
        } catch let err {
            print("ERROR: SettingsAdapter.updateSettings \(err)")
        }
    }
    
    //
    // Language Versions.db methods
    
    func getLanguagesSelected(selected: [String]) -> [Language] {
        let sql =  "SELECT iso, iso1, rightToLeft FROM Language WHERE iso" + genQuest(array: selected)
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
        let sql =  "SELECT iso, iso1, rightToLeft FROM Language WHERE iso NOT" + genQuest(array: selected)
        return getLanguages(sql: sql, selected: selected)
    }
    
    private func getLanguages(sql: String, selected: [String]) -> [Language] {
        var languages = [Language]()
        do {
            let currLocale = Locale.current
            let db: Sqlite3 = try Sqlite3.findDB(dbname: "Versions.db")
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: selected)
            for row in resultSet {
                let iso: String = row[0]!
                let iso1: String? = row[1]
                let rightToLeft: Bool = (row[2] == "T")
                let langLocale = Locale(identifier: iso)
                let name = langLocale.localizedString(forLanguageCode: iso)
                let localized = currLocale.localizedString(forLanguageCode: iso)
                if name != nil && localized != nil {
                    languages.append(Language(iso: iso, iso1: iso1, rightToLeft: rightToLeft,
                                              name: name!, localized: localized!))
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
        let sql =  "SELECT bibleId, abbr, iso, name, vname FROM Bible WHERE bibleId" +
            genQuest(array: selectedBibles) + " AND iso" + genQuest(array: selectedLanguages)
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
        let sql =  "SELECT bibleId, abbr, iso, name, vname FROM Bible WHERE bibleId NOT" +
            genQuest(array: selectedBibles) + " AND iso" + genQuest(array: selectedLanguages) +
            " ORDER BY abbr"
        return getBibles(sql: sql, selectedLanguages: selectedLanguages, selectedBibles: selectedBibles)
    }
    
    private func getBibles(sql: String, selectedLanguages: [String], selectedBibles: [String]) -> [Bible] {
        var bibles = [Bible]()
        do {
            let db: Sqlite3 = try Sqlite3.findDB(dbname: "Versions.db")
            let values = selectedBibles + selectedLanguages
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: values)
            for row in resultSet {
                let name = (row[4] != nil) ? row[4]! : row[3]!
                bibles.append(Bible(bibleId: row[0]!, abbr: row[1]!, iso: row[2]!, name: name))
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getBibles \(err)")
        }
        return bibles
    }
    
    private func genQuest(array: [String]) -> String {
        let quest = [String](repeating: "?", count: array.count)
        return " IN (" + quest.joined(separator: ",") + ")"
    }
}
