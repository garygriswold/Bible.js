//
//  SettingsAdapter.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 8/8/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation

class SettingsAdapter {
    
    /*
    settings selectedLanguages = “eng,fra,deu”
    if selected is null, populate from preferred languages
    
    settings selectedBibles = “ENGNIV,ENGKJV,ESVESV”
    if null select bibleId from Bibles where iso in (selectedLanguages) and recommended=’T’
    
    
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
