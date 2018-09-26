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
    private let adapter: SettingsAdapter
    
    init() {
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.adapter = SettingsAdapter()
        self.locales = adapter.getLanguageSettings()
        self.selected = [Bible]()
        var bibles: [String] = adapter.getBibleSettings()
        if bibles.count > 0 {
            for locale in self.locales {
                let some = adapter.getBiblesSelected(locale: locale, selectedBibles: bibles)
                self.selected += some
            }
        } else {
            let initial = BibleInitialSelect(adapter: adapter)
            self.selected = initial.getBiblesSelected(locales: locales)
            bibles = selected.map { $0.bibleId }
            adapter.updateSettings(bibles: self.selected)
        }
        self.available = [[Bible]]()
        for locale in self.locales {
            let available1 = adapter.getBiblesAvailable(locale: locale, selectedBibles: bibles)
            available.append(available1)
        }
        self.filtered = [Bible]()
        print("*** BibleModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit BibleModel ******")
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
    
    var settingsAdapter: SettingsAdapter {
        get { return self.adapter }
    }

    func getSelectedBible(row: Int) -> Bible? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
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
        let bible = self.getAvailableBible(section: indexPath.section - 4, row: indexPath.row)! // ??????????? safety
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
        let element: Bible = self.available[source.section - 4][source.row]
        self.available[source.section - 4].remove(at: source.row)
        self.selected.insert(element, at: destination.row)
        self.adapter.updateSettings(bibles: self.selected)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available[destination.section - 4].insert(element, at: destination.row)
        self.adapter.updateSettings(bibles: self.selected)
    }
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let bible = self.selected[selectedIndex.row]
        let localeIndex = self.findAvailableLocale(locale: bible.locale)
        let bibleList = self.available[localeIndex]
        let searchName = bible.name
        for index in 0..<bibleList.count {
            let bible = bibleList[index]
            if bible.name > searchName {
                return IndexPath(item: index, section: (localeIndex + 4)) // ??????? const
            }
        }
        return IndexPath(item: self.available.count, section: (localeIndex + 4)) // ????? const
    }
    
    private func findAvailableLocale(locale: Locale) -> Int {
        for index in 0..<available.count {
            let bibles = available[index]
            if bibles.count > 0 && bibles[0].locale == locale {
                return index
            }
        }
        return 0
    }

    func filterForSearch(searchText: String) {
    }
}
