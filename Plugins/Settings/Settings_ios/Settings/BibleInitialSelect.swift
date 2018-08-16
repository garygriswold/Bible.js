//
//  BibleSequence.swift
//  Settings
//
//  Created by Gary Griswold on 8/15/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// This class is used when the user first starts an App, and has not yet specified any preferences
// of Bible Versions.  This class is uses to sort iso3 languges in the order that might be most
// relevant to them, and then to sort the Bibles into the best sequence.
//

import Foundation
import Utility

class BibleInitialSelect {
    
    struct LanguageDetail : Equatable {
        let iso: String         // unique iso-1 and iso-3 codes
        let country: String?
        let score: Float
        
        static func == (lhs: LanguageDetail, rhs: LanguageDetail) -> Bool {
            return lhs.iso == rhs.iso
        }
    }
    
    private var adapter: SettingsAdapter
    private var selectedBibles: [Bible]?
    
    init(adapter: SettingsAdapter) {
        self.adapter = adapter
    }
    
    deinit {
        print("****** Deinit BibleSequence ******")
    }
    
    func getBiblesSelected(selectedLanguages: [Locale]) -> [Bible] {
        let details: [LanguageDetail] = self.getInitialLanguageDetails(languages: selectedLanguages)
        self.selectedBibles = self.getBiblesSelected(languages: selectedLanguages, languageDetail: details)
        self.adapter.updateSettings(bibles: self.selectedBibles!)
        return self.selectedBibles!
    }
    
    func getBibleSettings() -> [String] {
        if let bibles = self.selectedBibles {
            var result = [String]()
            for bible in bibles {
                result.append(bible.bibleId)
            }
            return result
        } else {
            return []
        }
    }
    
    /**
    * Iterate over all of a user's locales and get a list of iso3 languages
    * that is sorted by those locales and a score of each individual locale.
    */
    private func getInitialLanguageDetails(languages: [Locale]) -> [LanguageDetail] {
        var details = [LanguageDetail]()
        for locale in languages {
            let results = self.getOneInitialLanguageDetail(locale: locale)
            details += results
        }
        return details
    }
    
    /**
    * Retrieve all iso3 languages for a locale and sort those languages by a score that is
    * based upon population and country match with the locale
    */
    private func getOneInitialLanguageDetail(locale: Locale) -> [LanguageDetail] {
        var details = [LanguageDetail]()
        var sql: String
        if locale.languageCode?.count == 2 {
            sql = "SELECT iso3, country, pop FROM Language WHERE iso1 = ?"
        } else {
            sql = "SELECT iso3, country, pop FROM Language WHERE iso3 = ?"
        }
        do {
            let db = try self.adapter.getVersionsDB()
            let resultSet = try db.queryV1(sql: sql, values: [locale.languageCode])
            for row in resultSet {
                let country = row[1]
                var score: Float = (row[2] != nil) ? Float(row[2]!)! : 0.1 // set score to pop, default is 0.1
                if country != nil && locale.regionCode == country {
                    score *= 10.0
                } else if country == "*" {
                    score *= 5.0
                }
                let lang = LanguageDetail(iso: row[0]!, country: country, score: score)
                details.append(lang)
            }
            return details.sorted{ $0.score > $1.score } // sort desc by score
            // Should I limit the list size before I return it?
            
        } catch let err {
            print("ERROR: SettingsAdapter.updateSettings \(err)")
        }
        return []
    }
    
    /**
     * Using a sorted list of languages, retrieve the Bibles that match,
     * and sort the returned bibles into the order of the languages.
     *
     * Then within a language try do do additional matching on script to prioritize
     * the languages.
     *
     * Then limit to 3 or 4 versions in each of the original locales.
     */
    
    private func getBiblesSelected(languages: [Locale], languageDetail: [LanguageDetail]) -> [Bible] {
        let sql =  "SELECT bibleId, abbr, iso3, name, vname FROM Bible WHERE iso3" +
            self.adapter.genQuest(array: languageDetail)

        var bibles = [Bible]()
        var iso3s = [String]()
        for lang in languageDetail {
            iso3s.append(lang.iso)
        }
        do {
            let db: Sqlite3 = try self.adapter.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: iso3s)
            for row in resultSet {
                let name = (row[4] != nil) ? row[4]! : row[3]!
                bibles.append(Bible(bibleId: row[0]!, abbr: row[1]!, iso3: row[2]!, name: name))
            }
        } catch let err {
            print("ERROR: SettingsAdapter.getBibles \(err)")
        }
        // The locales are passed in here, because for each Locale that has a script code,
        // or language that could have a script code, I want to match on the script code of the
        // individual Bibles, and add to the score of those that match.
        
        // Sort results by Language Detail
        var map = [String: [Bible]]()
        for bible in bibles {
            if var bibleList = map[bible.iso3] {
                if bibleList.count < 3 { // Limit to 3 versions for each language
                    bibleList.append(bible)
                    map[bible.iso3] = bibleList // is this line needed?
                }
            } else {
                map[bible.iso3] = [bible]
            }
        }
        var sorted = [Bible]()
        for lang in languageDetail {
            if let found: [Bible] = map[lang.iso] {
                for one in found {
                    sorted.append(one)
                }
            }
        }
        return sorted
    }
}
