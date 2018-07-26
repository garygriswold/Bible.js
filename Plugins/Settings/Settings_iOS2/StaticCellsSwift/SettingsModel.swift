//
//  SettingsModel.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation

// This does not conform to naming, but only lang code could
struct UserLocale {
    let langIso1Code: String    // iso 2 char language from locale
    let variantCode: String?    // optional variant from locale
    let scriptCode: String?     // optional script from locale
    let countryCode: String     // country code from locale
    let languageCode: String    // FCBH 3 char language code
}

struct Language {
    let languageCode: String    // FCBH 3 char code
    let languageName: String    // name in its own language
    let englishName: String     // name in English
    let rightToLeft: Bool       // true if lang is Right to Left
    let localizedName: String   // name in language of the user
}

struct Version {
    let versionCode: String     // FCBH 3 char code is unique
    let languageCode: String    // FCBH 3 char language code
    let versionName: String     // Name in the language of the version
    let englishName: String     // Name of the version in English
    let organizationId: String  // This is placeholder, where is this information in FCBH?
    let organizationName: String // This is placeholder, where is this information in FCBH?
    let copyright: String       // This is placeholder, where is this information in FCBH?
}
///
/// This class should probably do as much directly from the database in order to simply logic.
///
class SettingsModel {
    
    var languages = [Language]()
    var langMap = [String : Language]()
    var langSelected = [String]()
    var langAvailable = [String]()
    
    var versions = [Version]()
    var versMap = [String : Version]()
    var versSelected = [String]()
    var versAvailable = [String]()
    
    func fillLanguages() {
        langSelected.append("ENG")
        langSelected.append("ARB")
        langSelected.append("CMN")
        // This is equivalent to select languageCode from selectedLanguages order by sequence;
        // Or possibly select languageCode from languages where sequence is not null order by sequence
        
        var langSelectedMap = [String : Bool]()
        for lang in langSelected {
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
            langMap[langCode] = lang
            if langSelectedMap[langCode] == nil {
                langAvailable.append(langCode)
                // This is equivalent to select languageCode from languages where languageCode not in (select languageCode from selectedlanguages)
                // Or, possibly select languageCode from languages where sequence is null order by languages
            }
        }
    }
    
    func fillVersions() {
        versSelected.append("ESV")
        versSelected.append("ERV-CMN")
        versSelected.append("ERV-ARB")
        
        var versSelectedMap = [String : Bool]()
        for vers in versSelected {
            versSelectedMap[vers] = true
        }
        
        versions.append(Version(versionCode: "KJV", languageCode: "ENG",
                                versionName: "King James Version",
                                englishName: "King James Version",
                                organizationId: "PD", organizationName: "Public Domain",
                                copyright: ""))
        versions.append(Version(versionCode: "WEB", languageCode: "ENG",
                                versionName: "World English Bible",
                                englishName: "World English Bible",
                                organizationId: "PD", organizationName: "Public Domain",
                                copyright: ""))
        versions.append(Version(versionCode: "ESV", languageCode: "ENG",
                                versionName: "English Standard Version",
                                englishName: "English Standard Version",
                                organizationId: "GP", organizationName: "Gospel Folio Press",
                                copyright: ""))
        versions.append(Version(versionCode: "NIV", languageCode: "ENG",
                                versionName: "New International Version",
                                englishName: "New International Version",
                                organizationId: "HAR", organizationName: "Harold Publishing",
                                copyright: ""))
        versions.append(Version(versionCode: "ERV-ENG", languageCode: "ENG",
                                versionName: "Easy Read Version",
                                englishName: "Easy Read Version",
                                organizationId: "BLI", organizationName: "Bible League International",
                                copyright: ""))
        versions.append(Version(versionCode: "ERV-CMN", languageCode: "CMN",
                                versionName: "圣经–普通话本",
                                englishName: "Chinese Union Version",
                                organizationId: "BLI", organizationName: "Bible League International",
                                copyright: "2016"))
        versions.append(Version(versionCode: "ERV-ARB", languageCode: "ARB",
                                versionName: "الكتاب المقدس ترجمة فان دايك",
                                englishName: "Van Dycke Bible",
                                organizationId: "BLI", organizationName: "Bible League International",
                                copyright: ""))
        
        for vers in versions {
            let versCode = vers.versionCode
            versMap[versCode] = vers
            if versSelectedMap[versCode] == nil {
                versAvailable.append(versCode)
            }
        }
    }
    
    func getSelectedLanguageCount() -> Int {
        ensureLanguages()
        return langSelected.count
    }
    
    func getAvailableLanguageCount() -> Int {
        ensureLanguages()
        return langAvailable.count
    }
    
    func getSelectedVersionCount() -> Int {
        ensureVersions()
        return versSelected.count
    }
    
    func getAvailableVersionCount() -> Int {
        ensureVersions()
        return versAvailable.count
    }
    
    func getSelectedLanguage(index: Int) -> Language {
        ensureLanguages()
        return langMap[langSelected[index]]! // what should I do about out of range?
    }
    
    func getAvailableLanguage(index: Int) -> Language {
        ensureLanguages()
        return langMap[langAvailable[index]]! // what should I do about out of range?
    }
    
    func getSelectedVersion(index: Int) -> Version {
        ensureVersions()
        return versMap[versSelected[index]]!
    }
    
    func getAvailableVersion(index: Int) -> Version {
        ensureVersions()
        return versMap[versAvailable[index]]!
    }
    
    func insertSelectedVersion(versionCode: String, at: Int) {
        self.versSelected.insert(versionCode, at: at)
    }
    
    func appendSelectedVersion(versionCode: String) {
        self.versSelected.append(versionCode)
    }
    
    func removeSelectedVersion(at: Int) {
        self.versSelected.remove(at: at)
    }
    
    func insertAvailableVersion(versionCode: String, at: Int) {
        self.versAvailable.insert(versionCode, at: at)
    }
    
    func removeAvailableVersion(at: Int) {
        self.versAvailable.remove(at: at)
    }
    
    private func ensureLanguages() {
        ensureVersions()
        if languages.count == 0 {
            fillLanguages()
        }
    }
    private func ensureVersions() {
        if versions.count == 0 {
            fillVersions()
        }
    }
}


