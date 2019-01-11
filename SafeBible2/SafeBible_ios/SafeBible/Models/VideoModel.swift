//
//  VideoModel.swift
//  SafeBible
//
//  Created by Gary Griswold on 1/11/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//
import Foundation

struct Video {
    let languageId: String
    let mediaId: String
    let mediaSource: String
    let title: String
    let lengthMS: Int // could be a string
    let HLS_URL: String
    let description: String?
}

struct VideoModel {
    
    var selected: [Video]
    
    init(iso3: String) {
        let country = Locale.current.regionCode
        let languageId = VersionsDB.shared.getJesusFilmLanguage(iso3: iso3, country: country)
        self.selected = VersionsDB.shared.getVideos(iso3: iso3, languageId: languageId)
    }
}
