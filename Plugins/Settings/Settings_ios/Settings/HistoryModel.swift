//
//  HistoryModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/18/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct Reference : Equatable {
    
    private static var bibleMap = [String:Bible]()
    
    let bibleId: String
    let bookId: String
    let bookName: String
    let chapter: Int
    let verse: Int
    
    static func == (lhs: Reference, rhs: Reference) -> Bool {
        return lhs.bibleId == rhs.bibleId &&
            lhs.bookId == rhs.bookId &&
            lhs.chapter == rhs.chapter &&
            lhs.verse == rhs.verse
    }
    
    var abbr: String {
        get { return self.bible.abbr }
    }
    
    var bibleName: String {
        get { return self.bible.name }
    }
    
    var s3KeyPrefix: String {
        get { return self.bible.s3KeyPrefix }
    }
    
    var s3Key: String {
        get { return self.bible.s3Key }
    }
    
    var bible: Bible {
        get {
            var bibl = Reference.bibleMap[self.bibleId]
            if bibl == nil {
                bibl = VersionsDB.shared.getBible(bibleId: self.bibleId)
                Reference.bibleMap[self.bibleId] = bibl
            }
            return bibl!
        }
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
    
    private var tableContents: TableContentsModel
    private var history = [Reference]()
    private var index = 0
    
    init() {
        self.history = SettingsDB.shared.getHistory()
        self.index = self.history.count - 1
        if self.history.count < 1 {
            /// How do I really get the preferred version, not this default
            let reference = Reference(bibleId: "ENGWEB", bookId: "JHN",
                                      bookName: "John", chapter: 3, verse: 1)
            self.history.append(reference)
            self.index = 0
            SettingsDB.shared.storeHistory(reference: self.history[0])
        }
        let curr = self.history.last!
        let bible = VersionsDB.shared.getBible(bibleId: curr.bibleId)! /// safety
        self.tableContents = TableContentsModel(bible: bible)
    }
    
    var currBible: Bible {
        get { return self.tableContents.bible }
    }
 
    var currBook: Book {
        get {
            return self.tableContents.getBook(bookId: self.current().bookId)! /// safety
        }
    }

    var currTableContents: TableContentsModel {
        get { return self.tableContents }
    }
    
    var historyCount: Int {
        get { return self.history.count }
    }
    
    var biblePage: BiblePage {
        get {
            let curr = self.current()
            return BiblePage(bible: self.currBible, bookId: curr.bookId, chapter: curr.chapter)
        }
    }
    
    func getHistory(row: Int) -> Reference {
        return (row >= 0 && row < self.history.count) ? self.history[row] : self.history[0]
    }

    mutating func changeBible(bible: Bible) {
        self.tableContents = TableContentsModel(bible: bible)
        if let top = self.history.last {
            let ref = Reference(bibleId: bible.bibleId, bookId: top.bookId, bookName: top.bookName,
                                chapter: top.chapter, verse: top.verse)
            self.add(reference: ref)
        } else {
            print("Unable to add history, because empty in changeBible")
        }
    }
    
    mutating func changeReference(book: Book, chapter: Int) {
        let bible = self.tableContents.bible
        let ref = Reference(bibleId: bible.bibleId, bookId: book.bookId, bookName: book.name,
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
    
    private mutating func add(reference: Reference) {
        if reference != self.current() {
            self.history.append(reference)
            self.index += 1
            SettingsDB.shared.storeHistory(reference: reference)
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
