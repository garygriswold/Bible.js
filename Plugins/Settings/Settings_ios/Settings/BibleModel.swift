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
    
    init(language: Language?) {
        let adapter = SettingsAdapter()
        var selected: [Bible]
        var available: [Bible]
        let start: Double = CFAbsoluteTimeGetCurrent()
        let locales = adapter.getLanguageSettings()
        var bibles: [String] = adapter.getBibleSettings()
        if bibles.count > 0 {
            selected = adapter.getBiblesSelected(locales: locales, selectedBibles: bibles)
        } else {
            let initial = BibleInitialSelect(adapter: adapter)
            selected = initial.getBiblesSelected(locales: locales)
            bibles = selected.map { $0.bibleId }
            adapter.updateSettings(bibles: selected)
        }
        if let lang = language {
            available = adapter.getBiblesAvailable(locales: [Locale(identifier: lang.iso)],
                                                             selectedBibles: bibles)
        } else {
            available = adapter.getBiblesAvailable(locales: locales, selectedBibles: bibles)
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
        let bible = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, bible: bible)
    }
    
    private func generateCell(tableView: UITableView, indexPath: IndexPath, bible: Bible) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
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

    /**
    * A better search would search starting with each word, but compare from
    * there to the end of the next word.
    */
    func filterForSearch(searchText: String) {
        print("****** INSIDE FILTER CONTENT FOR SEARCH ******")
        let searchFor = searchText.uppercased()
        self.filtered.removeAll()
        for vers in available {
            if vers.abbr.hasPrefix(searchFor) {
                self.filtered.append(vers)
            } else if vers.name.uppercased().hasPrefix(searchFor) {
                self.filtered.append(vers)
            } else {
                // This could be precomputed and stored for performance reasons
                let words: [String] = vers.name.components(separatedBy: " ")
                for word in words {
                    if word.uppercased().hasPrefix(searchFor) {
                        self.filtered.append(vers)
                        break // jump out of word loop, back to vers loop
                    }
                }
            }
        }
    }
}
