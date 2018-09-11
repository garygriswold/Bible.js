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
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func findAvailableInsertIndex(selectedIndex: Int) -> Int {
        let language = self.selected[selectedIndex]
        let searchName = language.localized
        for index in 0..<self.available.count {
            let language = self.available[index]
            if language.localized > searchName {
                return index
            }
        }
        return self.available.count
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
