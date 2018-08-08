//
//  SettingsAdapter.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 8/8/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation

class SettingsAdapter {
    
    func getLanguageSettings() -> [String] {
        // Add logic to get from settings
        // Add logic to get from device when absend, and update settings
        let settings = "eng,fra,deu"
        return settings.components(separatedBy: ",")
    }
    
    func updateLanguageSettings(languages: [String]) {
        
    }
    
    func getBibleSettings() -> [String] {
        // Add logic to get from settings
        // Add logic to get from recommended when absent, and update settings
        let settings = "ENGNIV,ENGKJV,ESVESV"
        return settings.components(separatedBy: ",")
    }
    
    func updateBibleSettings(bibles: [String]) {
        
    }
    
//    func getLanguagesSelected(selected: String) -> [Language] {
//        let sql =  "SELECT iso, name, iso1, rightToLeft FROM Language WHERE iso IN (?)"
//
//    }
    
 //   func getLanguagesAvailable(selected: String) -> [Language] {
 //       let sql =  "SELECT iso, name, iso1, rightToLeft FROM Language"
 //   }
    
    private func toQuotedString(array: [String]) -> String {
        return "'" + array.joined(separator: "','") + "'"
    }
    
    /*
    1. get selected languages
    select iso, name, iso1 from Language where iso in (selectedLanguages)
    
    2. get available languages
    select iso, name, iso1 from Language where iso not in (selectedLanguages)
    
    3. get selected version
    select bibleId, abbr, iso, name, vname from Bible where bibleId in (selectedBibles) and
    iso in (selectedLanguages)
    
    3. get available versions
    select bibleId, abbr, iso, name, vname, from Bible where bibleId not in (selectedBibles) and
    iso in (selectedLanguages)
*/
}
