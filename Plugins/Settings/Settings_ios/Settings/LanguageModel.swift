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
    private var selected: [Language]
    private var available: [Language]
    private var filtered = [Language]()
    
    init() {
        self.adapter = SettingsAdapter()
        let locales = self.adapter.getLanguageSettings()
        self.selected = self.adapter.getLanguagesSelected(selected: locales)
        let avail = self.adapter.getLanguagesAvailable(selected: locales)
        self.available = avail.sorted{ $0.localized < $1.localized }
    }
    
    deinit {
        print("***** deinit LanguageModel ******")
    }
    
    var settingsAdapter: SettingsAdapter {
        get { return self.adapter }
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
        cell.textLabel?.text = language.name
        cell.detailTextLabel?.text = language.localized
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let language = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        cell.textLabel?.text = language.name
        cell.detailTextLabel?.text = language.localized
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let language = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(language, at: destination)
        self.adapter.updateSettings(languages: self.selected)
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
        self.adapter.updateSettings(languages: self.selected)
        
        // The following I can do, but how do I add the bibles found to selected Bibles from Language DataModel
        //let bibles = self.adapter.getBiblesForLanguages(languages: [Locale(identifier: language.iso)])
        // Unfinished.
    }
    
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool) {
        let language = self.selected[source]
        self.selected.remove(at: source)
        self.available.insert(language, at: destination)
        if inSearch {
            self.filtered.insert(language, at: destination)
        }
        self.adapter.updateSettings(languages: self.selected)
    }
    
    func filterForSearch(searchText: String) {
        print("****** INSIDE FILTER CONTENT FOR SEARCH ******")
        let searchFor = searchText.lowercased()
        self.filtered.removeAll()
        for lang in available {
            if lang.name.lowercased().hasPrefix(searchFor) ||
                lang.localized.lowercased().hasPrefix(searchFor) {
                self.filtered.append(lang)
            }
        }
    }
}
