//
//  ModelInterface.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

struct Bible : Equatable {
    let bibleId: String     // FCBH 6 to 8 char code
    let abbr: String        // Version Abbreviation
    let iso3: String        // SIL 3 char SIL language code
    let name: String        // Name in the language, but sometimes in English
    let textBucket: String  // Name of bucket with text Bible
    let textId: String      // 2nd part of text s3Key
    let s3TextTemplate: String // Template of part of S3 key that identifies object
    let audioBucket: String?// Name of bucket with audio Bible
    let otDamId: String?    // Old Testament DamId
    let ntDamId: String?    // New Testament DamId
    let language: Language
    var isDownloaded: Bool?
    var tableContents: TableContentsModel?
    
    init(bibleId: String, abbr: String, iso3: String, name: String,
         textBucket: String, textId: String, s3TextTemplate: String,
         audioBucket: String?, otDamId: String?, ntDamId: String?,
         iso: String, script: String) {
        self.bibleId = bibleId
        self.abbr = abbr
        self.iso3 = iso3
        self.name = name
        self.textBucket = textBucket
        self.textId = textId
        self.s3TextTemplate = s3TextTemplate
        self.audioBucket = audioBucket
        self.otDamId = otDamId
        self.ntDamId = ntDamId
        self.language = Language(iso: iso, script: script)
    }
    
    static func == (lhs: Bible, rhs: Bible) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
}

protocol SettingsModel {
 
    var settingsAdapter: SettingsAdapter { get }
    var locales: [Language] { get }
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

