//
//  LanguageModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class LanguageModel : SettingsModelInterface {
    
    private let adapter: SettingsAdapter
    private var sequence: [String]
    private var selected: [Language]
    private var available: [Language]
    private var filtered = [Language]()
    
    init() {
        self.adapter = SettingsAdapter()
        self.sequence = self.adapter.getLanguageSettings()
        self.selected = self.adapter.getLanguagesSelected(selected: self.sequence)
        self.available = self.adapter.getLanguagesAvailable(selected: self.sequence)
    }
    
    deinit {
        print("***** deinit LanguageModel ******")
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
        return nil
    }
    func getSelectedLanguage(row: Int) -> Language? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
    }
    func getAvailableBible(row: Int) -> Bible? {
        return nil
    }
    func getAvailableLanguage(row: Int) -> Language? {
        return (row >= 0 && row < available.count) ? available[row] : nil
    }
    
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let language = selected[indexPath.row]
        let ownLocale = Locale(identifier: language.iso)
        cell.textLabel?.text = ownLocale.localizedString(forLanguageCode: language.iso)
        cell.detailTextLabel?.text = Locale.current.localizedString(forLanguageCode: language.iso)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let language = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        let ownLocale = Locale(identifier: language.iso)
        cell.textLabel?.text = ownLocale.localizedString(forLanguageCode: language.iso)
        cell.detailTextLabel?.text = Locale.current.localizedString(forLanguageCode: language.iso)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let version = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(version, at: destination)
    }
    
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool) {
        var language: Language
        if inSearch {
            language = self.filtered[source]
            guard let availableIndex = self.available.index(of: language) else {
                print("Item in filtered not found in available? \(language.iso)")
                return
            }
            self.filtered.remove(at: source)
            self.available.remove(at: availableIndex)
        } else {
            language = self.available[source]
            self.available.remove(at: source)
        }
        self.selected.insert(language, at: destination)
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
        let searchFor = searchText.lowercased()
        self.filtered.removeAll()
        for lang in available {
            if lang.name.lowercased().contains(searchFor) ||
                lang.name.lowercased().contains(searchFor) { // This needs to be able to search on localized??
                self.filtered.append(lang)
            }
        }
    }
}
