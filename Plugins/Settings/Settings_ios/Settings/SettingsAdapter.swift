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
    
    //
    // Language methods
    //
    
    func getLanguageSettings() -> [String] {
        // Add logic to get from settings
        // Add logic to get from device when absend, and update settings
        let settings = "eng,fra,deu"
        return settings.components(separatedBy: ",")
    }
    
    func updateLanguageSettings(languages: [String]) {
        //db.executeV1(sql: String, values: [Any?]) throws -> Int {}
    }
    
    func getLanguagesSelected(selected: [String]) -> [Language] {
        let sql =  "SELECT iso, iso1, rightToLeft FROM Language WHERE iso" + genQuest(array: selected)
        return getLanguages(sql: sql, selected: selected)
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
            print(err)
        }
        return languages
    }
    
    //
    // Bible methods
    //
    
    func getBibleSettings() -> [String] {
        // Add logic to get from settings
        // Add logic to get from recommended when absent, and update settings
        let settings = "ENGNIV,ENGKJV,ESVESV"
        return settings.components(separatedBy: ",")
    }
    
    func updateBibleSettings(bibles: [String]) {
        // db.executeV1(sql: String, values: [Any?]) throws -> Int {}
    }
    
    func getBiblesSelected(selectedLanguages: [String], selectedBibles: [String]) -> [Bible] {
        let sql =  "SELECT bibleId, abbr, iso, name, vname  FROM Bible WHERE bibleId" +
            genQuest(array: selectedBibles) + " AND iso" + genQuest(array: selectedLanguages)
        return getBibles(sql: sql, selectedLanguages: selectedLanguages, selectedBibles: selectedBibles)
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
                bibles.append(Bible(bibleId: row[0]!, abbr: row[1]!, iso: row[2]!, name: row[3]!, vname: row[4]))
            }
        } catch let err {
            print(err)
        }
        return bibles
    }
    
    private func genQuest(array: [String]) -> String {
        let quest = [String](repeating: "?", count: array.count)
        return " IN (" + quest.joined(separator: ",") + ")"
    }
}
