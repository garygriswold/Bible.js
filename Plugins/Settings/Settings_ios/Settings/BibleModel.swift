//
//  BibleModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class BibleModel : GenericModel<Bible>, SettingsModel {
    
    let locales: [Locale]
    var available2: [[Bible]]
    
    init() {
        let adapter = SettingsAdapter()
        var selected = [Bible]()
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.locales = adapter.getLanguageSettings()
        var bibles: [String] = adapter.getBibleSettings()
        if bibles.count > 0 {
            for locale in self.locales {
                let some = adapter.getBiblesSelected(locale: locale, selectedBibles: bibles)
                selected += some
            }
        } else {
            let initial = BibleInitialSelect(adapter: adapter)
            selected = initial.getBiblesSelected(locales: locales)
            bibles = selected.map { $0.bibleId }
            adapter.updateSettings(bibles: selected)
        }
        let available = [Bible]()
        self.available2 = [[Bible]]()
        var available1: [Bible]
        for locale in self.locales {
            available1 = adapter.getBiblesAvailable(locale: locale, selectedBibles: bibles)
            available2.append(available1)
        }
        super.init(adapter: adapter, selected: selected, available: available)
    
        print("*** BibleModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit BibleModel ******")
    }
    
    func getAvailableBibleCount(section: Int) -> Int {
        let bibles: [Bible] = self.available2[section]
        return bibles.count
    }
    
    func getAvailableBible(section: Int, row: Int) -> Bible? {
        let bibles = self.available2[section]
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
    
    func moveAvailableToSelected(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.available2[source.section - 4][source.row]
        self.available2[source.section - 4].remove(at: source.row)
        self.selected.insert(element, at: destination.row)
        self.updateSelectedSettings(item: element)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available2[destination.section - 4].insert(element, at: destination.row)
        self.updateSelectedSettings(item: element)
    }
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let bible = self.selected[selectedIndex.row]
        let localeIndex = self.findAvailableLocale(locale: bible.locale)
        let bibleList = self.available2[localeIndex]
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
        for index in 0..<available2.count {
            let bibles = available2[index]
            if bibles.count > 0 && bibles[0].locale == locale {
                return index
            }
        }
        return 0
    }

    func filterForSearch(searchText: String) {
    }
}
