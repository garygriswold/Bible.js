//
//  BibleModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

class BibleModel : SettingsModel {
    
    let locales: [Locale]
    var selected: [Bible]
    var available: [[Bible]]
    var filtered: [Bible]
    var oneLanguage: Language? // Used only when settingsViewType == .oneLang
    private let adapter: SettingsAdapter
    private let availableSection: Int
    
    init(availableSection: Int, language: Language?) {
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.adapter = SettingsAdapter()
        self.availableSection = availableSection
        self.oneLanguage = language
        self.locales = adapter.getLanguageSettings()
        self.selected = [Bible]()
        var bibles: [String] = adapter.getBibleSettings()
        if bibles.count > 0 {
            self.selected = adapter.getBiblesSelected(locales: self.locales, selectedBibles: bibles)
        } else {
            let initial = BibleInitialSelect(adapter: adapter)
            self.selected = initial.getBiblesSelected(locales: locales)
            bibles = selected.map { $0.bibleId }
            adapter.updateSettings(bibles: self.selected)
        }
        self.available = [[Bible]]()
        if self.oneLanguage != nil {
            let avail = adapter.getBiblesAvailable(locale: oneLanguage!.locale, selectedBibles: bibles)
            self.available.append(avail)
        } else {
            for locale in self.locales {
                let available1 = adapter.getBiblesAvailable(locale: locale, selectedBibles: bibles)
                self.available.append(available1)
            }
        }
        self.filtered = [Bible]()
        print("*** BibleModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit BibleModel ******")
    }
    
    var settingsAdapter: SettingsAdapter {
        get { return adapter }
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
    
    func getSelectedLanguage(row: Int) -> Language? {
        return nil
    }

    func getSelectedBible(row: Int) -> Bible? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
    }
    
    func getAvailableLanguage(row: Int) -> Language? {
        return nil
    }
    
    func getAvailableBibleCount(section: Int) -> Int {
        let bibles: [Bible] = self.available[section]
        return bibles.count
    }
    
    func getAvailableBible(section: Int, row: Int) -> Bible? {
        let bibles = self.available[section]
        if let bible = (row < bibles.count) ? bibles[row] : nil {
            return bible
        }
        return nil
    }

    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let bible = selected[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, bible: bible)
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let section = indexPath.section - self.availableSection
        let bible = self.getAvailableBible(section: section, row: indexPath.row)! // ??????????? safety
        return self.generateCell(tableView: tableView, indexPath: indexPath, bible: bible)
    }
    
    private func generateCell(tableView: UITableView, indexPath: IndexPath, bible: Bible) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let element = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(element, at: destination)
        self.adapter.updateSettings(bibles: self.selected)
    }
    
    func moveAvailableToSelected(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.available[source.section - self.availableSection][source.row]
        self.available[source.section - self.availableSection].remove(at: source.row)
        self.selected.insert(element, at: destination.row)
        self.adapter.updateSettings(bibles: self.selected)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available[destination.section - self.availableSection].insert(element, at: destination.row)
        self.adapter.updateSettings(bibles: self.selected)
    }
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let bible = self.selected[selectedIndex.row]
        var localeIndex: Int
        if self.oneLanguage != nil {
            localeIndex = 0
        } else {
            localeIndex = self.findAvailableLocale(locale: bible.locale)
        }
        let bibleList = self.available[localeIndex]
        let searchName = bible.name
        for index in 0..<bibleList.count {
            let bible = bibleList[index]
            if bible.name > searchName {
                return IndexPath(item: index, section: (localeIndex + self.availableSection))
            }
        }
        return IndexPath(item: bibleList.count, section: (localeIndex + self.availableSection))
    }
    
    private func findAvailableLocale(locale: Locale) -> Int {
        for index in 0..<locales.count {
            let loc = locales[index]
            if loc == locale {
                return index
            }
        }
        return locales.count - 1
    }

    func filterForSearch(searchText: String) {
    }
}
