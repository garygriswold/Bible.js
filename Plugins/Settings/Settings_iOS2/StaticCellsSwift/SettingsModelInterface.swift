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
struct UserLocale {
    let langIso1Code: String    // iso 2 char language from locale
    let variantCode: String?    // optional variant from locale
    let scriptCode: String?     // optional script from locale
    let countryCode: String     // country code from locale
    let languageCode: String    // FCBH 3 char language code
}

struct Language : Equatable {
    let languageCode: String    // FCBH 3 char code
    let languageName: String    // name in its own language
    let englishName: String     // name in English
    let rightToLeft: Bool       // true if lang is Right to Left
    let localizedName: String   // name in language of the user
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.languageCode == rhs.languageCode
    }
}

// NOTE: Equatable might prove inefficient with a large list.  Wait and see. But its advantage
// is that it is only used when needed.  The disadvantage is that it is used to pass over the
// entire list.  The alternative would be to have a hash map of versionCode for everything in available,
// but it would need to be maintained as the available list changes.
struct Version : Equatable {
    let versionCode: String     // FCBH 3 char code is unique
    let languageCode: String    // FCBH 3 char language code
    let versionName: String     // Name in the language of the version
    let englishName: String     // Name of the version in English
    let organizationId: String  // This is placeholder, where is this information in FCBH?
    let organizationName: String // This is placeholder, where is this information in FCBH?
    let copyright: String       // This is placeholder, where is this information in FCBH?
    
    static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.versionCode == rhs.versionCode
    }
}

protocol SettingsModelInterface {
 
    var selectedCount: Int { get }
    var availableCount: Int { get }
    var filteredCount: Int { get }
    func getSelectedVersion(row: Int) -> Version?
    func getSelectedLanguage(row: Int) -> Language?
    func getAvailableVersion(row: Int) -> Version?
    func getAvailableLanguage(row: Int) -> Language?
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell
    func moveSelected(source: Int, destination: Int)
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool)
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool)
    func filterForSearch(searchText: String)
}
