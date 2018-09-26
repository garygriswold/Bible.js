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
        var element: Bible
        //if inSearch {
        //    element = self.filtered[source.row]
        //    guard let availableIndex = self.available.index(of: element) else {
        //        print("Item in filtered not found in available? \(element)")
        //        return
        //    }
        //    self.filtered.remove(at: source.row)
        //    self.available.remove(at: availableIndex)
        //} else {
        element = self.available[source.row]
        self.available.remove(at: source.row)
        //}
        self.selected.insert(element, at: destination.row)
        self.updateSelectedSettings(item: element)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.selected[source.row]
        self.selected.remove(at: source.row)
        // must get the locale from Element
        // using locale must lookup bible list in available
        //
        self.available.insert(element, at: destination.row)
        if inSearch {
            self.filtered.insert(element, at: destination.row)
        }
        self.updateSelectedSettings(item: element)
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
