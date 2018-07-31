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
        
        languages.append(Language(languageCode: "ENG", languageName: "English", englishName: "English",
                                  rightToLeft: false, localizedName: "English"))
        languages.append(Language(languageCode: "FRN", languageName: "Francaise", englishName: "French",
                                  rightToLeft: false, localizedName: "French"))
        languages.append(Language(languageCode: "DEU", languageName: "Deutsch", englishName: "German",
                                  rightToLeft: false, localizedName: "German"))
        languages.append(Language(languageCode: "SPN", languageName: "Espanol", englishName: "Spanish",
                                  rightToLeft: false, localizedName: "Spanish"))
        languages.append(Language(languageCode: "ARB", languageName: "العربية", englishName: "Arabic",
                                  rightToLeft: true, localizedName: "Arabic"))
        languages.append(Language(languageCode: "CMN", languageName: "汉语, 漢語", englishName: "Chinese",
                                  rightToLeft: false, localizedName: "Chinese"))
        
        for lang in languages {
            let langCode = lang.languageCode
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
    
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        let language = selected[indexPath.row]
        cell.textLabel?.text = language.localizedName
        cell.detailTextLabel?.text = language.languageName
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        let language = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        cell.textLabel?.text = language.localizedName
        cell.detailTextLabel?.text = language.languageName
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
                print("Item in filtered not found in available? \(language.languageCode)")
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
            if lang.languageName.lowercased().contains(searchFor) ||
                lang.localizedName.lowercased().contains(searchFor) {
                self.filtered.append(lang)
            }
        }
    }
}
