//
//  SettingsModel.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation

struct userLocale {
    let langCode: String
    let variantCode: String?
    let scriptCode: String?
    let countryCode: String
}

struct Language {
    let langCode: String    // iso 2 char code
    let langName: String    // name in language of user
    let localName: String   // name in its own language
    
}

struct Version {
    let langCode: String        // iso 2 char code
    let versionCode: String     // versionCode is unique
    let versionAbbr: String     // versionCode, but not unique
    let versionName: String
    let direction: String       // ltr or rtl
    let ownerCode: String       //
    let ownerName: String       //
}


struct ActiveVersion {
    let langCode: String        // iso 2 char code
    let silCode: String         // 3 char sil lang code of version
    let versionCode: String     // versionCode is unique
    let versionAbbr: String     // versionCode, but not unique
    let versionName: String
    let direction: String       // ltr or rtl
    let ownerCode: String       //
    let ownerName: String       //
    let ownerURL: String        //
    let copyright: String       //
}

class SettingsModel {
    
    var languages = [Language]()
    var versions = [Version]()
    
    func fillLanguages() {
        languages.append(Language(langCode: "en", langName: "English", localName: "English"))
        languages.append(Language(langCode: "fr", langName: "French", localName: "Francaise"))
        languages.append(Language(langCode: "de", langName: "German", localName: "Deutsch"))
    }
    
    func fillVersions() {
        versions.append(Version(langCode: "en", versionCode: "KJVPD", versionAbbr: "KJV",
                                versionName: "King James Version", direction: "ltr",
                                ownerCode: "PD", ownerName: "Public Domain"))
        versions.append(Version(langCode: "en", versionCode: "WEB", versionAbbr: "WEB",
                                versionName: "World English Bible", direction: "ltr",
                                ownerCode: "PD", ownerName: "Public Domain"))
        versions.append(Version(langCode: "en", versionCode: "ESV", versionAbbr: "ESV",
                                versionName: "English Standard Version", direction: "ltr",
                                ownerCode: "GP", ownerName: "Gospel Folio Press"))
        versions.append(Version(langCode: "en", versionCode: "NIV", versionAbbr: "NIV",
                                versionName: "New International Version", direction: "ltr",
                                ownerCode: "HAR", ownerName: "Harold Publishing"))
    }
    
    func getLanguageCount() -> Int {
        if languages.count == 0 {
            fillLanguages()
        }
        return languages.count
    }
    
    func getVersionCount() -> Int {
        if versions.count == 0 {
            fillVersions()
        }
        return versions.count
    }
    
    func getLanguage(index: Int) -> Language {
        if languages.count == 0 {
            fillLanguages()
        }
        return languages[index] // what should I do about out of range?
    }
    
    func getVersion(index: Int) -> Version {
        if versions.count == 0 {
            fillVersions()
        }
        return versions[index]
    }
}


