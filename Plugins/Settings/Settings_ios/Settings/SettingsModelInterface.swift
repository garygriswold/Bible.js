//
//  ModelInterface.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

struct Language : Equatable {
    let iso3: String        // sil 3 char code
    let iso1: String?       // 2 char iso code
    let name: String        // name in its own language
    let localized: String   // name localized to user language
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso3 == rhs.iso3
    }
}

// NOTE: Equatable might prove inefficient with a large list.  Wait and see. But its advantage
// is that it is only used when needed.  The disadvantage is that it is used to pass over the
// entire list.  The alternative would be to have a hash map of versionCode for everything in available,
// but it would need to be maintained as the available list changes.
struct Bible : Equatable {
    let bibleId: String     // FCBH 6 to 8 char code
    let abbr: String        // Version Abbreviation
    let iso3: String        // SIL 3 char SIL language code
    let name: String        // Name in the language, but sometimes in English
    //let recommended: Bool   // Version added as default, when language is selected.
    
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
