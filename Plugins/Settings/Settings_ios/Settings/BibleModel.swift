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
    var available2: [Locale: [Bible]]
    
    init() {
        let adapter = SettingsAdapter()
        var selected: [Bible]
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.locales = adapter.getLanguageSettings()
        var bibles: [String] = adapter.getBibleSettings()
        if bibles.count > 0 {
            selected = adapter.getBiblesSelected(locales: locales, selectedBibles: bibles)
        } else {
            let initial = BibleInitialSelect(adapter: adapter)
            selected = initial.getBiblesSelected(locales: locales)
            bibles = selected.map { $0.bibleId }
            adapter.updateSettings(bibles: selected)
        }
        let available = [Bible]()
        self.available2 = [Locale: [Bible]]()
        var available1: [Bible]
        for locale in self.locales {
            available1 = adapter.getBiblesAvailable(locale: locale, selectedBibles: bibles)
            available2[locale] = available1
        }
        super.init(adapter: adapter, selected: selected, available: available)
    
        print("*** BibleModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit BibleModel ******")
    }
    
    func getAvailableBibleCount(section: Int) -> Int {
        if let locale = (section < self.locales.count) ? self.locales[section] : nil {
            if let bibles = self.available2[locale] {
                return bibles.count
            }
        }
        return 0
    }
    
    func getAvailableBible(section: Int, row: Int) -> Bible? {
        if let locale = (section < self.locales.count) ? self.locales[section] : nil {
            if let bibles = self.available2[locale] {
                if let bible = (row < bibles.count) ? bibles[row] : nil {
                    return bible
                }
            }
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
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let bible = self.selected[selectedIndex.row]
        let searchName = bible.abbr
        for index in 0..<self.available.count {
            let bible = self.available[index]
            if bible.abbr > searchName {
                return IndexPath(item: index, section: selectedIndex.section + 1)
            }
        }
        return IndexPath(item: self.available.count, section: selectedIndex.section + 1)
    }

    func filterForSearch(searchText: String) {
    }
}
