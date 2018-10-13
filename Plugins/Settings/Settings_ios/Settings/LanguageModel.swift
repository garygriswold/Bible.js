//
//  LanguageModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

class LanguageModel : SettingsModel {
    
    let locales: [Locale]
    var selected: [Language]
    var available: [Language]
    var filtered: [Language]
    private let adapter: SettingsAdapter
    private let availableSection: Int
    
    init(availableSection: Int) {
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.adapter = SettingsAdapter()
        self.availableSection = availableSection
        self.locales = adapter.getLanguageSettings()
        self.selected = adapter.getLanguagesSelected(selected: locales)
        self.available = adapter.getLanguagesAvailable(selected: locales)
        self.filtered = [Language]()
        print("*** LanguageModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit LanguageModel ******")
    }
    
    var settingsAdapter: SettingsAdapter {
        get { return adapter }
    }
    
    var selectedCount: Int {
        get { return self.selected.count }
    }
    
    var availableCount: Int {
        get { return self.available.count }
    }
    
    var filteredCount: Int {
        get { return self.filtered.count }
    }
    
    func getSelectedLanguage(row: Int) -> Language? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
    }
    
    func getSelectedBible(row: Int) -> Bible? {
        return nil
    }
    
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let language = selected[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, language: language)
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let language = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, language: language)
    }
    
    private func generateCell(tableView: UITableView, indexPath: IndexPath, language: Language) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = language.name
        cell.detailTextLabel?.text = language.localized
        cell.selectionStyle = .none
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let element = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(element, at: destination)
        self.adapter.updateSettings(languages: self.selected)
    }
    
    func moveAvailableToSelected(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        var element: Language
        if inSearch {
            element = self.filtered[source.row]
            guard let availableIndex = self.available.index(of: element) else {
                print("Item in filtered not found in available? \(element)")
                return
            }
            self.filtered.remove(at: source.row)
            self.available.remove(at: availableIndex)
        } else {
            element = self.available[source.row]
            self.available.remove(at: source.row)
        }
        self.selected.insert(element, at: destination.row)
        self.adapter.updateSettings(languages: self.selected)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Language = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available.insert(element, at: destination.row)
        if inSearch {
            self.filtered.insert(element, at: destination.row)
        }
        self.adapter.updateSettings(languages: self.selected)
    }
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let language = self.selected[selectedIndex.row]
        let searchName = language.localized
        for index in 0..<self.available.count {
            let language = self.available[index]
            if language.localized > searchName {
                return IndexPath(item: index, section: selectedIndex.section + self.availableSection)
            }
        }
        return IndexPath(item: self.available.count, section: selectedIndex.section + self.availableSection)
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
