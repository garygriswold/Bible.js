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
    
    init() {
        let start: Double = CFAbsoluteTimeGetCurrent()
        let adapter = SettingsAdapter()
        let locales = adapter.getLanguageSettings()
        let selected = adapter.getLanguagesSelected(selected: locales)
        let avail = adapter.getLanguagesAvailable(selected: locales)
        let available = avail.sorted{ $0.localized < $1.localized }
        super.init(adapter: adapter, selected: selected, available: available)
        print("*** LanguageModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit LanguageModel ******")
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
