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
            for bible in selected {
                bibles.append(bible.bibleId)
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "bibleCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let bible = selected[indexPath.row]
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bibleCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let bible = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool) {
        var bible: Bible
        if inSearch {
            bible = self.filtered[source]
            guard let availableIndex = self.available.index(of: bible) else {
                print("Item in filtered not found in available? \(bible.bibleId)")
                return
            }
            self.filtered.remove(at: source)
            self.available.remove(at: availableIndex)
        } else {
            bible = self.available[source]
            self.available.remove(at: source)
        }
        self.selected.insert(bible, at: destination)
        self.adapter.updateSettings(bibles: self.selected)
    }
    
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool) {
        let version = self.selected[source]
        self.selected.remove(at: source)
        self.available.insert(version, at: destination)
        if inSearch {
            self.filtered.insert(version, at: destination)
        }
        self.adapter.updateSettings(bibles: self.selected)
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
