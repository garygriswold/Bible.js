//
//  LanguageModel.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class LanguageModel : SettingsModelInterface {
    
    private var languages = [Language]() // temporary, I think
    private var sequence = [String]()
    private var selected = [Language]()
    private var available = [Language]()
    private var filtered = [Language]()
    
    init() {
        fill()
    }
    
    func fill() {
        sequence.append("ENG")
        sequence.append("ARB")
        sequence.append("CMN")
        // This is equivalent to select languageCode from selectedLanguages order by sequence;
        // Or possibly select languageCode from languages where sequence is not null order by sequence
        
        var langSelectedMap = [String : Bool]()
        for lang in sequence {
            langSelectedMap[lang] = true
        }
        
        languages.append(Language(iso: "ENG", name: "English", iso1: "en",
                                  rightToLeft: false))
        languages.append(Language(iso: "FRN", name: "Francaise", iso1: "fr",
                                  rightToLeft: false))
        languages.append(Language(iso: "DEU", name: "Deutsch", iso1: "de",
                                  rightToLeft: false))
        languages.append(Language(iso: "SPN", name: "Espanol", iso1: "es",
                                  rightToLeft: false))
        languages.append(Language(iso: "ARB", name: "العربية", iso1: "ar",
                                  rightToLeft: true))
        languages.append(Language(iso: "CMN", name: "汉语, 漢語", iso1: "zh",
                                  rightToLeft: false))
        
        for lang in languages {
            let langCode = lang.iso
            if langSelectedMap[langCode] == nil {
                available.append(lang)
                // This is equivalent to select languageCode from languages where languageCode not in (select languageCode from selectedlanguages)
                // Or, possibly select languageCode from languages where sequence is null order by languages
            } else {
                selected.append(lang)
            }
        }
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
        cell.detailTextLabel?.text = language.name
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator // only works when not editing
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let language = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        cell.textLabel?.text = language.name
        cell.detailTextLabel?.text = language.name
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
