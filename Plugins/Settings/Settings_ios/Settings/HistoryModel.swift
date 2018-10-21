//
//  HistoryModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/18/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct Reference : Equatable {
    let bibleId: String
    let abbr: String
    let bookId: String
    let chapter: Int
    let verse: Int
    
    static func == (lhs: Reference, rhs: Reference) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
    
    func toString() -> String {
        return "\(self.bibleId) \(self.bookId):\(self.chapter):\(self.verse)"
    }
}

struct HistoryModel {
    
    static var shared = HistoryModel()
    
    private var bible: Bible
    private var history = [Reference]()
    private var index = 0
    
    init() {
        self.bible = Bible(bibleId: "ENGESV", abbr: "ESV", iso3: "eng", name: "English Standard",
                           locale: Locale(identifier: "en"))
        self.history = SettingsDB.shared.getHistory()
        self.index = self.history.count - 1
        if self.index < 0 {
            self.bible = Bible(bibleId: "ENGESV", abbr: "ESV", iso3: "eng", name: "English Standard",
                               locale: Locale(identifier: "en"))
            self.history.append(Reference(bibleId: "ENGESV", abbr: "ESV", bookId: "JHN",
                                          chapter: 3, verse: 1))
            self.index = 0
            SettingsDB.shared.storeHistory(reference: self.history[0])
        }
    }
    
    func currBible() -> Bible {
        return self.bible
    }
    
    mutating func add(reference: Reference) {
        self.history.append(reference)
        self.index += 1
        SettingsDB.shared.storeHistory(reference: reference)
    }
    /*
    mutating func add(bibleId: String, bookId: String, chapter: Int, verse: Int) {
        self.add(history: History(bibleId: bibleId, bookId: bookId, chapter: chapter, verse: verse))
    }
    
    mutating func add(bookId: String, chapter: Int, verse: Int) {
        if let top = self.history.last {
            self.add(history: History(bibleId: top.bibleId, bookId: bookId, chapter: chapter, verse: verse))
        } else {
            print("Unable to add history, because empty in addBook")
        }
    }
    
    mutating func add(chapter: Int, verse: Int) {
        if let top = self.history.last {
            self.add(history: History(bibleId: top.bibleId, bookId: top.bookId, chapter: chapter,
                                      verse: verse))
        } else {
            print("Unable to add history, because empty in addChapter")
        }
    }
    */
    mutating func changeBible(bible: Bible) {
        self.bible = bible
        if let top = self.history.last {
            let ref = Reference(bibleId: bible.bibleId, abbr: bible.abbr, bookId: top.bookId,
                                chapter: top.chapter, verse: top.verse)
            self.add(reference: ref)
        } else {
            print("Unable to add history, because empty in changeBible")
        }
    }
    
    func current() -> Reference {
        return self.history[self.index]
    }
    
    mutating func back() -> Reference? {
        self.index -= 1
        return (self.index >= 0 && self.index < self.history.count) ? self.history[self.index] : nil
    }
    
    mutating func forward() -> Reference? {
        self.index += 1
        return (self.index >= 0 && self.index < self.history.count) ? self.history[self.index] : nil
    }
}
