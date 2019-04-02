//
//  BibleInitialSelect.swift
//  Settings
//
//  Created by Gary Griswold on 8/15/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// This class is used when the user first starts an App, and has not yet specified any preferences
// of Bible Versions.  This class uses the user's language preferences in the sequence the user entered
//
// This version drops country code from the locale and matches version based upon language and script
//

import Utility

struct BibleInitialSelect {

    private var adapter: SettingsAdapter
    
    init(adapter: SettingsAdapter) {
        self.adapter = adapter
    }
    
    func getBiblesSelected(locales: [Language]) -> [Bible] {
        let bibles = self.adapter.getAllBibles()
        var selected = self.searchLocales(bibles: bibles, locales: locales) // match w/o countryCode
        if selected.count == 0 {
            selected = self.searchLocales(bibles: bibles, locales: [Language(identifier: "en")])
        }
        return selected
    }
    
    private func searchLocales(bibles: [Bible], locales: [Language]) -> [Bible] {
        var selected = [Bible]()
        for locale in locales {
            for bible in bibles {
                if locale == bible.language {
                    selected.append(bible)
                }
            }
        }
        return selected
    }
}
