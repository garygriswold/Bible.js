//
//  BibleModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

struct Bible : Equatable {
    let bibleId: String     // FCBH 6 to 8 char code
    let abbr: String        // Version Abbreviation
    let iso3: String        // SIL 3 char SIL language code
    let name: String        // Name in the language, but sometimes in English
    let textBucket: String  // Name of bucket with text Bible
    let textId: String      // 2nd part of text s3Key
    let s3TextTemplate: String // Template of part of S3 key that identifies object
    let audioBucket: String?// Name of bucket with audio Bible
    let otDamId: String?    // Old Testament DamId
    let ntDamId: String?    // New Testament DamId
    let language: Language
    var isDownloaded: Bool?
    var tableContents: TableContentsModel?
    
    init(bibleId: String, abbr: String, iso3: String, name: String,
         textBucket: String, textId: String, s3TextTemplate: String,
         audioBucket: String?, otDamId: String?, ntDamId: String?,
         iso: String, script: String) {
        self.bibleId = bibleId
        self.abbr = abbr
        self.iso3 = iso3
        self.name = name
        self.textBucket = textBucket
        self.textId = textId
        self.s3TextTemplate = s3TextTemplate
        self.audioBucket = audioBucket
        self.otDamId = otDamId
        self.ntDamId = ntDamId
        self.language = Language(iso: iso, script: script)
    }
    
    static func == (lhs: Bible, rhs: Bible) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
}

class BibleModel : SettingsModel {
    
    let locales: [Language]
    var selected: [Bible]
    var available: [[Bible]]
    var filtered: [Bible] // deprecated, not used
    var oneLanguage: Language? // Used only when settingsViewType == .oneLang
    private let adapter: SettingsAdapter
    private let availableSection: Int
    
    init(availableSection: Int, language: Language?, selectedOnly: Bool) {
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.adapter = SettingsAdapter()
        self.availableSection = availableSection
        self.oneLanguage = language
        let prefLocales = SettingsDB.shared.getLanguageSettings()
        self.selected = [Bible]()
        var bibles: [String] = SettingsDB.shared.getBibleSettings()
        if bibles.count > 0 {
            self.selected = adapter.getBiblesSelected(locales: prefLocales, selectedBibles: bibles)
        } else {
            let initial = BibleInitialSelect(adapter: adapter)
            self.selected = initial.getBiblesSelected(locales: prefLocales)
            bibles = selected.map { $0.bibleId }
            SettingsDB.shared.updateSettings(bibles: self.selected)
        }
        let selectedLocales = Set(self.selected.map { $0.language.identifier })
        var tempLocales = [Language]()
        self.available = [[Bible]]()
        if !selectedOnly {
            if self.oneLanguage != nil {
                let avail = adapter.getBiblesAvailable(locale: oneLanguage!, selectedBibles: bibles)
                self.available.append(avail)
            } else {
                for locale in prefLocales {
                    let available1 = adapter.getBiblesAvailable(locale: locale, selectedBibles: bibles)
                    if available1.count > 0 || selectedLocales.contains(locale.identifier) {
                        tempLocales.append(locale)
                        self.available.append(available1)
                    }
                }
            }
        }
        self.locales = tempLocales
        self.filtered = [Bible]()
        print("*** BibleModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit BibleModel ******")
    }
    
    var settingsAdapter: SettingsAdapter {
        get { return adapter }
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
    
    func getSelectedLanguage(row: Int) -> Language? {
        return nil
    }

    func getSelectedBible(row: Int) -> Bible? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
    }
    
    func getAvailableLanguage(row: Int) -> Language? {
        return nil
    }
    
    func getAvailableBibleCount(section: Int) -> Int {
        let bibles: [Bible] = self.available[section]
        return bibles.count
    }
    
    func getAvailableBible(section: Int, row: Int) -> Bible? {
        let bibles = self.available[section]
        if let bible = (row < bibles.count) ? bibles[row] : nil {
            return bible
        }
        return nil
    }

    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let bible = selected[indexPath.row]
        return self.generateCell(tableView: tableView, indexPath: indexPath, bible: bible)
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let section = indexPath.section - self.availableSection
        let bible = self.getAvailableBible(section: section, row: indexPath.row)! // ??????????? safety
        return self.generateCell(tableView: tableView, indexPath: indexPath, bible: bible)
    }
    
    private func generateCell(tableView: UITableView, indexPath: IndexPath, bible: Bible) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.backgroundColor = AppFont.backgroundColor
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.selectionStyle = .default
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let element = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(element, at: destination)
        SettingsDB.shared.updateSettings(bibles: self.selected)
    }
    
    func moveAvailableToSelected(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.available[source.section - self.availableSection][source.row]
        self.available[source.section - self.availableSection].remove(at: source.row)
        self.selected.insert(element, at: destination.row)
        SettingsDB.shared.updateSettings(bibles: self.selected)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Bible = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available[destination.section - self.availableSection].insert(element, at: destination.row)
        SettingsDB.shared.updateSettings(bibles: self.selected)
    }
    
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath {
        let bible = self.selected[selectedIndex.row]
        var localeIndex: Int
        if self.oneLanguage != nil {
            localeIndex = 0
        } else {
            localeIndex = self.findAvailableLocale(locale: bible.language)
        }
        let bibleList = self.available[localeIndex]
        let searchName = bible.name
        for index in 0..<bibleList.count {
            let bible = bibleList[index]
            if bible.name > searchName {
                return IndexPath(item: index, section: (localeIndex + self.availableSection))
            }
        }
        return IndexPath(item: bibleList.count, section: (localeIndex + self.availableSection))
    }
    
    private func findAvailableLocale(locale: Language) -> Int {
        if let index = self.locales.index(of: locale) {
            return index
        } else {
            return self.locales.count - 1
        }
    }

    func filterForSearch(searchText: String) {
    }
}
