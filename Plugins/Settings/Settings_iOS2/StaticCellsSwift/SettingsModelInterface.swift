//
//  ModelInterface.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

// This does not conform to naming, but only lang code could
/*
struct UserLocale {
    let langIso1Code: String    // iso 2 char language from locale
    let variantCode: String?    // optional variant from locale
    let scriptCode: String?     // optional script from locale
    let countryCode: String     // country code from locale
    let languageCode: String    // FCBH 3 char language code
}
*/
struct Language : Equatable {
    let iso: String         // sil 3 char code
    let name: String        // name in its own language
    let iso1: String        // 2 char iso code
    let rightToLeft: Bool
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso == rhs.iso
    }
}

// NOTE: Equatable might prove inefficient with a large list.  Wait and see. But its advantage
// is that it is only used when needed.  The disadvantage is that it is used to pass over the
// entire list.  The alternative would be to have a hash map of versionCode for everything in available,
// but it would need to be maintained as the available list changes.
struct Bible : Equatable {
    let bibleId: String     // FCBH 6 to 8 char code
    let abbr: String        // Version Abbreviation
    let iso: String         // SIL 3 char language code
    let name: String        // Name in the language of the version
    let vname: String       // Name of the version in English
    
    static func == (lhs: Bible, rhs: Bible) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
}

protocol SettingsModelInterface {
 
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
