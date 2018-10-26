//
//  BibleTextModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/25/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

struct BiblePage {
    let bible: Bible
    let book: Book
    let reference: Reference
    var html: String
}

struct BibleTextModel {
    
    var pages: [BiblePage]
    
    
    
}

// Load page from database, bibleId is database name
// Select by reference

