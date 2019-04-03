//
//  LanguageModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

struct Language : Equatable {
    let iso: String         // iso1 code or iso3 code if iso1 does not apply
    let script: String?     // script code
    let country: String?    // country code
    let identifier: String  // This should be the iso_script identifer, country is ignored
    
    var fullIdentifier: String {
        get {
            return (self.country != nil) ? self.identifier + "-" + self.country! : self.identifier
        }
    }
    
    var englishName: String {
        get {
            return Locale(identifier: self.identifier).localizedString(forLanguageCode: "en")!
        }
    }
    
    var langScript: String {
        get {
            return (self.script != nil) ? self.iso + self.script! : self.iso
        }
    }
    
    var name: String {
        get {
            if let nam = Locale(identifier: self.identifier).localizedString(forIdentifier: self.identifier) {
                return nam
            } else {
                print("ERROR: Lang name Localization in own locale failed for \(self.identifier)")
                return self.englishName
            }
        }
    }
    
    var localized: String {
        get {
            if let nam = Locale.current.localizedString(forIdentifier: self.identifier) {
                return nam
            } else {
                print("ERROR: Lang name Localization in current locale failed for \(self.identifier)")
                return self.englishName
            }
        }
    }
    
    /** Used to populate Language from preferredLanguages */
    init(identifier: String) {
        let parts = identifier.split(separator: "-")
        self.iso = String(parts[0])
        var tmpScript: String? = nil
        var tmpCountry: String? = nil
        for index in 1..<parts.count {
            let part = parts[index]
            switch part.count {
            case 2:
                tmpCountry = String(part)
            case 4:
                tmpScript = String(part)
            default:
                print("ERROR: Unrecognized \(part) in \(identifier)")
            }
        }
        self.script = tmpScript
        self.country = tmpCountry
        self.identifier = (self.script != nil) ? self.iso + "-" + self.script! : self.iso
    }
    
    /** Used to populate Language from Language table and from Bible table */
    init(iso: String, script: String) {
        self.iso = iso
        self.script = (script.count > 0) ? script : nil
        self.country = nil
        self.identifier = (self.script != nil) ? iso + "-" + script : iso
    }
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso == rhs.iso && lhs.script == rhs.script
    }
    
    static func === (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso == rhs.iso && lhs.script == rhs.script && lhs.country == rhs.country
    }
}


class LanguageModel : SettingsModel {
    
    let locales: [Language]
    var selected: [Language]
    var available: [Language]
    var filtered: [Language]
    private let adapter: SettingsAdapter
    private let availableSection: Int
    
    init(availableSection: Int) {
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.adapter = SettingsAdapter()
        self.availableSection = availableSection
        self.locales = adapter.getLanguageSettings()
        self.selected = adapter.getLanguagesSelected(selected: locales)
        self.available = adapter.getLanguagesAvailable(selected: locales)
        self.filtered = [Language]()
        print("*** LanguageModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit LanguageModel ******")
    }
    
    var settingsAdapter: SettingsAdapter {
        get { return adapter }
    }
    
    var selectedCount: Int {
        get { return self.selected.count }
    }
    
    var availableCount: Int {
        get { return self.available.count }
    }
    
    var filteredCount: Int {
        get { return self.filtered.count }
    }
    
    func getSelectedLanguage(row: Int) -> Language? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
    }
    
    func getSelectedBible(row: Int) -> Bible? {
        return nil
    }
    
    func getAvailableLanguage(row: Int) -> Language? {
        return (row >= 0 && row < available.count) ? available[row] : nil
    }
    
    func getAvailableBible(section: Int, row: Int) -> Bible? {
        return nil
    }
    
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let language = selected[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, language: language)
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let language = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, language: language)
    }
    
    private func generateCell(tableView: UITableView, indexPath: IndexPath, language: Language) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.backgroundColor = AppFont.backgroundColor
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = language.name
        cell.detailTextLabel?.text = language.localized
        cell.selectionStyle = .default
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let element = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(element, at: destination)
        self.adapter.updateSettings(languages: self.selected)
    }
    
    func moveAvailableToSelected(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        var element: Language
        if inSearch {
            element = self.filtered[source.row]
            guard let availableIndex = self.available.index(of: element) else {
                print("Item in filtered not found in available? \(element)")
                return
            }
            self.filtered.remove(at: source.row)
            self.available.remove(at: availableIndex)
        } else {
            element = self.available[source.row]
            self.available.remove(at: source.row)
        }
        self.selected.insert(element, at: destination.row)
        self.adapter.updateSettings(languages: self.selected)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Language = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available.insert(element, at: destination.row)
        if inSearch {
            self.filtered.insert(element, at: destination.row)
        }
        self.adapter.updateSettings(languages: self.selected)
    }
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let language = self.selected[selectedIndex.row]
        let searchName = language.localized
        for index in 0..<self.available.count {
            let language = self.available[index]
            if language.localized > searchName {
                return IndexPath(item: index, section: selectedIndex.section + self.availableSection)
            }
        }
        return IndexPath(item: self.available.count, section: selectedIndex.section + self.availableSection)
    }

    func filterForSearch(searchText: String) {
        print("****** INSIDE FILTER CONTENT FOR SEARCH ******")
        let searchFor = searchText.lowercased()
        self.filtered.removeAll()
        for lang in available {
            if lang.name.lowercased().hasPrefix(searchFor) ||
                lang.localized.lowercased().hasPrefix(searchFor) {
                self.filtered.append(lang)
            }
        }
    }
}
