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
    private var book: Book
    private var tableContents: TableContentsModel
    private var history = [Reference]()
    private var index = 0
    
    init() {
        self.bible = Bible(bibleId: "ENGWEB", abbr: "WEB", iso3: "eng", name: "World English",
                           locale: Locale(identifier: "en"))
        self.book = Book(bookId: "JHN", ordinal: 25, name: "John", lastChapter: 28)
        self.tableContents = TableContentsModel(bible: self.bible)
        self.history = SettingsDB.shared.getHistory()
        self.index = self.history.count - 1
        if self.index < 0 {
            self.bible = Bible(bibleId: "ENGWEB", abbr: "WEB", iso3: "eng", name: "English Standard",
                               locale: Locale(identifier: "en"))
            self.book = Book(bookId: "JHN", ordinal: 25, name: "John", lastChapter: 28)
            self.tableContents = TableContentsModel(bible: self.bible)
            self.history.append(Reference(bibleId: "ENGWEB", abbr: "WEB", bookId: "JHN",
                                          chapter: 3, verse: 1))
            self.index = 0
            SettingsDB.shared.storeHistory(reference: self.history[0])
        }
    }
    
    var currBible: Bible {
        get { return self.bible }
    }
    
    var currBook: Book {
        get { return self.book }
    }
    
    var currTableContents: TableContentsModel {
        get { return self.tableContents }
    }

    mutating func changeBible(bible: Bible) {
        self.bible = bible
        self.tableContents = TableContentsModel(bible: self.bible)
        if let top = self.history.last {
            let ref = Reference(bibleId: bible.bibleId, abbr: bible.abbr, bookId: top.bookId,
                                chapter: top.chapter, verse: top.verse)
            self.add(reference: ref)
        } else {
            print("Unable to add history, because empty in changeBible")
        }
    }
    
    mutating func changeReference(book: Book, chapter: Int) {
        self.book = book
        let ref = Reference(bibleId: self.bible.bibleId, abbr: self.bible.abbr, bookId: book.bookId,
                            chapter: chapter, verse: 1)
        self.add(reference: ref)
    }
    
//    mutating func changeChapter(chapter: Int) {
//        if let top = self.history.last {
//            let ref = Reference(bibleId: top.bibleId, abbr: top.abbr, bookId: top.bookId,
//                                chapter: chapter, verse: 1)
//            self.add(reference: ref)
//        } else {
//            print("Unable to add history, because empty in changeChapter")
//        }
//    }
    
    private mutating func add(reference: Reference) {
        self.history.append(reference)
        self.index += 1
        SettingsDB.shared.storeHistory(reference: reference)
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
