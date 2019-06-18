//
//  LanguageModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

struct Language : Equatable {
    let iso: String         // iso1 code or iso3 code if iso1 does not apply
    let script: String?     // script code
    let country: String?    // country code
    let identifier: String  // This should be the iso_script identifer, country is ignored
    
    var fullIdentifier: String {
        get {
            return (self.country != nil) ? self.identifier + "-" + self.country! : self.identifier
        }
    }
    
    var englishName: String {
        get {
            return Locale(identifier: self.identifier).localizedString(forLanguageCode: "en")!
        }
    }
    
    var langScript: String {
        get {
            return (self.script != nil) ? self.iso + self.script! : self.iso
        }
    }
    
    var name: String {
        get {
            if let nam = Locale(identifier: self.identifier).localizedString(forIdentifier: self.identifier) {
                return nam
            } else {
                print("ERROR: Lang name Localization in own locale failed for \(self.identifier)")
                return self.englishName
            }
        }
    }
    
    var localized: String {
        get {
            if let nam = Locale.current.localizedString(forIdentifier: self.identifier) {
                return nam
            } else {
                print("ERROR: Lang name Localization in current locale failed for \(self.identifier)")
                return self.englishName
            }
        }
    }
    
    /** Used to populate Language from preferredLanguages */
    init(identifier: String) {
        let parts = identifier.split(separator: "-")
        self.iso = String(parts[0])
        var tmpScript: String? = nil
        var tmpCountry: String? = nil
        for index in 1..<parts.count {
            let part = parts[index]
            switch part.count {
            case 2:
                tmpCountry = String(part)
            case 4:
                tmpScript = String(part)
            default:
                print("ERROR: Unrecognized \(part) in \(identifier)")
            }
        }
        self.script = tmpScript
        self.country = tmpCountry
        self.identifier = (self.script != nil) ? self.iso + "-" + self.script! : self.iso
    }
    
    /** Used to populate Language from Language table and from Bible table */
    init(iso: String, script: String) {
        self.iso = iso
        self.script = (script.count > 0) ? script : nil
        self.country = nil
        self.identifier = (self.script != nil) ? iso + "-" + script : iso
    }
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso == rhs.iso && lhs.script == rhs.script
    }
    
    static func === (lhs: Language, rhs: Language) -> Bool {
        return lhs.iso == rhs.iso && lhs.script == rhs.script && lhs.country == rhs.country
    }
}


class LanguageModel : SettingsModel {
    
    let locales: [Language]
    var selected: [Language]
    var available: [Language]
    var filtered: [Language]
    private let availableSection: Int
    
    init(availableSection: Int) {
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.availableSection = availableSection
        self.locales = SettingsDB.shared.getLanguageSettings()
        self.selected = VersionsDB.shared.getLanguagesSelected(selected: locales)
        self.available = VersionsDB.shared.getLanguagesAvailable(selected: locales)
        self.filtered = [Language]()
        print("*** LanguageModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    deinit {
        print("***** deinit LanguageModel ******")
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
    
    func getAvailableLanguage(row: Int) -> Language? {
        return (row >= 0 && row < available.count) ? available[row] : nil
    }
    
    func getAvailableBible(section: Int, row: Int) -> Bible? {
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
        cell.backgroundColor = AppFont.backgroundColor
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = language.name
        cell.detailTextLabel?.text = language.localized
        cell.selectionStyle = .default
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let element = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(element, at: destination)
        SettingsDB.shared.updateSettings(languages: self.selected)
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
        SettingsDB.shared.updateSettings(languages: self.selected)
    }
    
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool) {
        let element: Language = self.selected[source.row]
        self.selected.remove(at: source.row)
        self.available.insert(element, at: destination.row)
        if inSearch {
            self.filtered.insert(element, at: destination.row)
        }
        SettingsDB.shared.updateSettings(languages: self.selected)
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
    
    /** This method exists solely to creat a file of valid Language codes, i.e. AppleLang.txt */
    static func getAllAvailableLocales() {
        let locales = Locale.availableIdentifiers
        for locale in locales.sorted() {
            let parts = locale.components(separatedBy: "_")
            if parts.count == 1 || parts[parts.count - 1].count != 2 {
                let iso1 = parts[0]
                let script = (parts.count > 1) ? parts[1] : ""
                // There is a bug in generating name?
                let lang = Language(iso: iso1, script: script)
                print("\(locale)|\(parts[0])|\(script)|\(lang.englishName)")
            }
        }
    }
/*
    static func testScriptDefaults() {
        let az = Locale(identifier: "az") // az||Azerbaijani (Arabic)
        print("script of az: \(az.scriptCode)")
        let az_cyrl = Locale(identifier: "az-Cyrl") // az|Cyrl|Azerbaijani (Cyrillic)
        print("script of az_cyrl: \(az_cyrl.scriptCode)")
        let az_latn = Locale(identifier: "az-Latn") //az|Latn|Azerbaijani (Latin)
        print("script of az_latn: \(az_latn.scriptCode)")
        let bs = Locale(identifier: "bs") // bs||Bosnian (Arabic)
        print("script of bs: \(bs.scriptCode)")
        let bs_cyrl = Locale(identifier: "bs-Cyrl") // bs|Cyrl|Bosnian (Cyrillic)
        print("script of bs_cyrl: \(bs_cyrl.scriptCode)")
        let bs_latn = Locale(identifier: "bs-Latn") // bs|Latn|Bosnian (Latin)
        print("script of bs_latn: \(bs_latn.scriptCode)")
        let ms = Locale(identifier: "ms") // ms||Malay (Latin)
        print("script of ms: \(ms.scriptCode)")
        let ms_arab = Locale(identifier: "ms-Arab") // ms|Arab|Malay (Arabic)
        print("script of ms_arab: \(ms_arab.scriptCode)")
        let pa = Locale(identifier: "pa") // pa||Punjabi ??
        print("script of pa: \(pa.scriptCode)")
        let pa_arab = Locale(identifier: "pa-Arab") // pa|Arab|Punjabi (Arabic)
        print("script of pa_arab: \(pa_arab.scriptCode)")
        let pa_guru = Locale(identifier: "pa-Guru") // pa|Guru|Punjabi (Gurmukhi)
        print("script of pa_guru: \(pa_guru.scriptCode)")
        let shi = Locale(identifier: "shi") // shi||Tachelhit (Arabic)
        print("script of shi: \(shi.scriptCode)")
        let shi_latn = Locale(identifier: "shi-Latn") // shi|Latn|Tachelhit (Latin)
        print("script of shi_latn: \(shi_latn.scriptCode)")
        let shi_tfng = Locale(identifier: "shi-Tfng") // shi|Tfng|Tachelhit (Tifinagh)
        print("script of shi_tfng: \(shi_tfng.scriptCode)")
        let sr = Locale(identifier: "sr") // sr||Serbian ??
        print("script of sr: \(sr.scriptCode)")
        let sr_cyrl = Locale(identifier: "sr-Cyrl") // sr|Cyrl|Serbian (Cyrillic)
        print("script of sr_cyrl: \(sr_cyrl.scriptCode)")
        let sr_latn = Locale(identifier: "sr-Latn") // sr|Latn|Serbian (Latin)
        print("script of sr_latn: \(sr_latn.scriptCode)")
        let uz = Locale(identifier: "uz") // uz||Uzbek ??
        print("script of uz: \(uz.scriptCode)")
        let uz_arab = Locale(identifier: "uz-Arab") // uz|Arab|Uzbek (Arabic)
        print("script of uz_arab: \(uz_arab.scriptCode)")
        let uz_cyrl = Locale(identifier: "uz-Cyrl") // uz|Cyrl|Uzbek (Cyrillic)
        print("script of uz_cyrl: \(uz_cyrl.scriptCode)")
        let uz_latn = Locale(identifier: "uz-Latn") // uz|Latn|Uzbek (Latin)
        print("script of uz_latn: \(uz_latn.scriptCode)")
        let vai = Locale(identifier: "vai") // vai||Vai ??
        print("script of vai: \(vai.scriptCode)")
        let vai_latn = Locale(identifier: "vai-Latn") // vai|Latn|Vai (Latin)
        print("script of vai_latn: \(vai_latn.scriptCode)")
        let vai_vaii = Locale(identifier: "vai-Vaii") // vai|Vaii|Vai (Vai)
        print("script of vai_vaii: \(vai_vaii.scriptCode)")
        let yue = Locale(identifier: "yue") // yue||Cantonese ??
        print("script of yue: \(yue.scriptCode)")
        let yue_hans = Locale(identifier: "yue-Hans") // yue|Hans|Cantonese (Simplified)
        print("script of yue_hans: \(yue_hans.scriptCode)")
        let yue_hant = Locale(identifier: "yue-Hant") // yue|Hant|Cantonese (Traditional)
        print("script of yue_hant: \(yue_hant.scriptCode)")
        let zh = Locale(identifier: "zh") // zh||Chinese ??
        print("script of zh: \(zh.scriptCode)")
        let zh_hans = Locale(identifier: "zh-Hans") // zh|Hans|Chinese (Simplified)
        print("script of zh_hans: \(zh_hans.scriptCode)")
        let zh_hant = Locale(identifier: "zh-Hant") // zh|Hant|Chinese (Traditional)
        print("script of zh_hant: \(zh_hant.scriptCode)")
    }
 */
}
