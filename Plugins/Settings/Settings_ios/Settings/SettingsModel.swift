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
    func getSelectedBible(row: Int) -> Bible?
    func getSelectedLanguage(row: Int) -> Language?
    func getAvailableBible(row: Int) -> Bible?
    func getAvailableLanguage(row: Int) -> Language?
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell
    func moveSelected(source: Int, destination: Int)
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool)
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool)
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath
    func filterForSearch(searchText: String)
}

class GenericModel<Element> where Element : Equatable {
  
    private let adapter: SettingsAdapter
    var selected: [Element]
    var available: [Element]
    var filtered: [Element]
    
    init(adapter: SettingsAdapter, selected: [Element], available: [Element]) {
        self.adapter = adapter
        self.selected = selected
        self.available = available
        self.filtered = [Element]()
    }
    
    var settingsAdapter: SettingsAdapter {
        get { return self.adapter }
    }
    
    var selectedCount: Int {
        get { return selected.count }
    }
    
    var availableCount: Int {
        get { return available.count }
    }
    
    var filteredCount: Int {
        get { return filtered.count }
    }
    // I attempted to replace this with Generic methods, but their generic type needs to
    // be used when they are typed or instantiated
    func getSelectedBible(row: Int) -> Bible? {
        return (row >= 0 && row < selected.count) ? selected[row] as? Bible : nil
    }
    func getSelectedLanguage(row: Int) -> Language? {
        return (row >= 0 && row < selected.count) ? selected[row] as? Language : nil
    }
    func getAvailableBible(row: Int) -> Bible? {
        return (row >= 0 && row < available.count) ? available[row] as? Bible : nil
    }
    func getAvailableLanguage(row: Int) -> Language? {
        return (row >= 0 && row < available.count) ? available[row] as? Language : nil
    }
    
    func moveSelected(source: Int, destination: Int) {
        let element = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(element, at: destination)
        self.updateSelectedSettings(item: element)
    }
    
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool) {
        var element: Element
        if inSearch {
            element = self.filtered[source]
            guard let availableIndex = self.available.index(of: element) else {
                print("Item in filtered not found in available? \(element)")
                return
            }
            self.filtered.remove(at: source)
            self.available.remove(at: availableIndex)
        } else {
            element = self.available[source]
            self.available.remove(at: source)
        }
        self.selected.insert(element, at: destination)
        self.updateSelectedSettings(item: element)
    }
    
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool) {
        let element: Element = self.selected[source]
        self.selected.remove(at: source)
        self.available.insert(element, at: destination)
        if inSearch {
            self.filtered.insert(element, at: destination)
        }
        self.updateSelectedSettings(item: element)
    }
 
    /**
     * The Element is passed in only to discern its type
     */
    private func updateSelectedSettings(item: Element) {
        if item is Language {
            self.adapter.updateSettings(languages: self.selected as! [Language])
        } else if item is Bible {
            self.adapter.updateSettings(bibles: self.selected as! [Bible])
        } else {
            print("ERROR: Unknown element type in GenericModel.updateSelectedSettings")
        }
    }
}
