//
//  ModelInterface.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

struct Language : Equatable {
    let iso: String         // unique iso-1 and iso-3 for those with no iso-1
    var locale: Locale      // Locale of language (languageCode, regionCode, scriptCode)
    let name: String        // name in its own language
    let localized: String   // name localized to user language
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso == rhs.iso
    }
}

struct Bible : Equatable {
    let bibleId: String     // FCBH 6 to 8 char code
    let abbr: String        // Version Abbreviation
    let iso3: String        // SIL 3 char SIL language code
    let name: String        // Name in the language, but sometimes in English
    let s3KeyPrefix: String // Part of S3 key that is common to all objects of a Bible
    let s3Key: String       // Template of part of S3 key that identifies object
    let locale: Locale      // The user locale that is associated
    var tableContents: TableContentsModel?
    
    init(bibleId: String, abbr: String, iso3: String, name: String,
         s3KeyPrefix: String, s3Key: String, locale: Locale) {
        self.bibleId = bibleId
        self.abbr = abbr
        self.iso3 = iso3
        self.name = name
        self.s3KeyPrefix = s3KeyPrefix
        self.s3Key = s3Key
        self.locale = locale
    }
    
    static func == (lhs: Bible, rhs: Bible) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
}

protocol SettingsModel {
 
    var settingsAdapter: SettingsAdapter { get }
    var locales: [Locale] { get }
    var selectedCount: Int { get }
    var availableCount: Int { get }
    var filteredCount: Int { get }
    func getSelectedLanguage(row: Int) -> Language?
    func getSelectedBible(row: Int) -> Bible?
    func getAvailableLanguage(row: Int) -> Language?
    func getAvailableBible(section: Int, row: Int) -> Bible?
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell
    func moveSelected(source: Int, destination: Int)
    func moveAvailableToSelected(source: IndexPath, destination: IndexPath, inSearch: Bool)
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool)
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath
    func filterForSearch(searchText: String)
}
