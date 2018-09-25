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

    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let bible = selected[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, bible: bible)
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let index = indexPath.section - 4
        let locale = self.locales[index] // need safety
        let bibles = self.available2[locale]! // need safety
        let bible = bibles[indexPath.row] // need safety
        //let bible = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
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
    
    func findAvailableInsertIndex(selectedIndex: Int) -> Int {
        let bible = self.selected[selectedIndex]
        let searchName = bible.abbr
        for index in 0..<self.available.count {
            let bible = self.available[index]
            if bible.abbr > searchName {
                return index
            }
        }
        return self.available.count
    }

    func filterForSearch(searchText: String) {
    }
}
