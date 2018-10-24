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
    let bibleName: String
    let bookId: String
    let bookName: String
    let chapter: Int
    let verse: Int
    
    static func == (lhs: Reference, rhs: Reference) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
    
    func description() -> String {
        return "\(self.bookName) \(self.chapter):\(self.verse)"
    }
    
    func toString() -> String {
        return "\(self.bibleId) \(self.bookId):\(self.chapter):\(self.verse)"
    }
}

struct HistoryModel {
    
    static var shared = HistoryModel()
    
    private var book: Book
    private var tableContents: TableContentsModel
    private var history = [Reference]()
    private var index = 0
    
    init() {
        let bible = Bible(bibleId: "ENGWEB", abbr: "WEB", iso3: "eng", name: "World English",
                           locale: Locale(identifier: "en"))
        self.book = Book(bookId: "JHN", ordinal: 25, name: "John", lastChapter: 28)
        self.tableContents = TableContentsModel(bible: bible)
        self.history = SettingsDB.shared.getHistory()
        self.index = self.history.count - 1
        if self.index < 0 {
            let bible = Bible(bibleId: "ENGWEB", abbr: "WEB", iso3: "eng", name: "English Standard",
                               locale: Locale(identifier: "en"))
            self.book = Book(bookId: "JHN", ordinal: 25, name: "John", lastChapter: 28)
            self.tableContents = TableContentsModel(bible: bible)
            self.history.append(Reference(bibleId: "ENGWEB", abbr: "WEB",
                                          bibleName: "World English", bookId: "JHN",
                                          bookName: "John",
                                          chapter: 3, verse: 1))
            self.index = 0
            SettingsDB.shared.storeHistory(reference: self.history[0])
        }
    }
    
    //var currBible: Bible {
    //    get { return self.bible }
    //}
    
    var currBook: Book {
        get { return self.book }
    }
    
    var currTableContents: TableContentsModel {
        get { return self.tableContents }
    }
    
    var historyCount: Int {
        get { return self.history.count }
    }
    
    func getHistory(row: Int) -> Reference {
        return (row >= 0 && row < self.history.count) ? self.history[row] : self.history[0]
    }

    mutating func changeBible(bible: Bible) {
        //self.bible = bible
        self.tableContents = TableContentsModel(bible: bible)
        if let top = self.history.last {
            let ref = Reference(bibleId: bible.bibleId, abbr: bible.abbr, bibleName: bible.name,
                                bookId: top.bookId, bookName: top.bookName,
                                chapter: top.chapter, verse: top.verse)
            self.add(reference: ref)
        } else {
            print("Unable to add history, because empty in changeBible")
        }
    }
    
    mutating func changeReference(book: Book, chapter: Int) {
        let bible = self.tableContents.bible
        self.book = book
        let ref = Reference(bibleId: bible.bibleId, abbr: bible.abbr, bibleName: bible.name,
                            bookId: book.bookId, bookName: book.name,
                            chapter: chapter, verse: 1)
        self.add(reference: ref)
    }
    
    mutating func changeReference(reference: Reference) {
        if reference.bibleId != self.tableContents.bible.bibleId {
            if let bible = VersionsDB.shared.getBible(bibleId: reference.bibleId) {
                self.tableContents = TableContentsModel(bible: bible)
            }
        }
        self.add(reference: reference)
    }
    
    mutating func clear() {
        let top = self.current()
        self.history.removeAll()
        self.index = -1
        SettingsDB.shared.clearHistory()
        self.add(reference: top)
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
