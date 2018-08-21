//
//  ModelInterface.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class Language : Equatable {
    let iso: String         // unique iso-1 and iso-3 for those with no iso-1
    var locale: Locale      // Locale of language (languageCode, regionCode, scriptCode)
    let name: String        // name in its own language
    let localized: String   // name localized to user language
    
    init(iso:String, locale: Locale, name: String, localized: String) {
        self.iso = iso
        self.locale = locale
        self.name = name
        self.localized = localized
    }
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso == rhs.iso
    }
}

class Bible : Equatable {
    let bibleId: String     // FCBH 6 to 8 char code
    let abbr: String        // Version Abbreviation
    let iso3: String        // SIL 3 char SIL language code
    let name: String        // Name in the language, but sometimes in English
    
    init(bibleId: String, abbr: String, iso3: String, name: String) {
        self.bibleId = bibleId
        self.abbr = abbr
        self.iso3 = iso3
        self.name = name
    }
    
    static func == (lhs: Bible, rhs: Bible) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
}

protocol SettingsModel {
 
    var settingsAdapter: SettingsAdapter { get }
    var selectedCount: Int { get }
    var availableCount: Int { get }
    var filteredCount: Int { get }
    func getSelectedBible(row: Int) -> Bible?
    func getSelectedLanguage(row: Int) -> Language?
    func getAvailableBible(row: Int) -> Bible?
    func getAvailableLanguage(row: Int) -> Language?
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell
    func moveSelected(source: Int, destination: Int)
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool)
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool)
    func filterForSearch(searchText: String)
}
