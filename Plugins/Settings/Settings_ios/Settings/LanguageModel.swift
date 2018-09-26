//
//  LanguageModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class LanguageModel : GenericModel<Language>, SettingsModel {
    
    let locales: [Locale]
    
    init() {
        let start: Double = CFAbsoluteTimeGetCurrent()
        let adapter = SettingsAdapter()
        self.locales = adapter.getLanguageSettings()
        let selected = adapter.getLanguagesSelected(selected: locales)
        let available = adapter.getLanguagesAvailable(selected: locales)
        super.init(adapter: adapter, selected: selected, available: available)
        print("*** LanguageModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit LanguageModel ******")
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
        //cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        cell.selectionStyle = .none
        return cell
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
        self.updateSelectedSettings(item: element)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Language = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available.insert(element, at: destination.row)
        if inSearch {
            self.filtered.insert(element, at: destination.row)
        }
        self.updateSelectedSettings(item: element)
    }
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let language = self.selected[selectedIndex.row]
        let searchName = language.localized
        for index in 0..<self.available.count {
            let language = self.available[index]
            if language.localized > searchName {
                return IndexPath(item: index, section: selectedIndex.section + 1)
            }
        }
        return IndexPath(item: self.available.count, section: selectedIndex.section + 1)
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
