//
//  VersionModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class BibleModel : SettingsModelInterface {
    
    private let adapter: SettingsAdapter
    private var languages: [String]
    private var sequence: [String]
    private var selected: [Bible]
    private var available: [Bible]
    private var filtered = [Bible]()
    
    init(language: Language?) {
        self.adapter = SettingsAdapter()
        self.languages = self.adapter.getLanguageSettings()
        self.sequence = self.adapter.getBibleSettings()
        self.selected = self.adapter.getBiblesSelected(selectedLanguages: self.languages, selectedBibles: self.sequence)
        if let lang = language {
            self.available = self.adapter.getBiblesAvailable(selectedLanguages: [lang.iso],
                                                             selectedBibles: self.sequence)
        } else {
            self.available = self.adapter.getBiblesAvailable(selectedLanguages: self.languages,
                                                             selectedBibles: self.sequence)
        }
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
    
    func getSelectedBible(row: Int) -> Bible? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
    }
    func getSelectedLanguage(row: Int) -> Language? {
        return nil
    }
    func getAvailableBible(row: Int) -> Bible? {
        return (row >= 0 && row < available.count) ? available[row] : nil
    }
    func getAvailableLanguage(row: Int) -> Language? {
        return nil
    }
    
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bibleCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let bible = selected[indexPath.row]
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bibleCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let bible = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let version = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(version, at: destination)
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
    }
    
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool) {
        let version = self.selected[source]
        self.selected.remove(at: source)
        self.available.insert(version, at: destination)
        if inSearch {
            self.filtered.insert(version, at: destination)
        }
    }
    
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
