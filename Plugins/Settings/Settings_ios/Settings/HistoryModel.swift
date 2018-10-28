//
//  HistoryModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/18/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

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
        let curr = self.history[self.index]
        self.tableContents = TableContentsModel(bible: curr.bible)
    }
    
    var currBible: Bible {
        get { return self.current().bible }
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
        get { return BiblePage(reference: self.current()) }
    }
    
    func getHistory(row: Int) -> Reference {
        return (row >= 0 && row < self.history.count) ? self.history[row] : self.history[0]
    }

    mutating func changeBible(bible: Bible) {
        self.tableContents = TableContentsModel(bible: bible)
        let curr = self.current()
        let ref = Reference(bibleId: bible.bibleId, bookId: curr.bookId, bookName: curr.bookName,
                            chapter: curr.chapter, verse: curr.verse)
        self.add(reference: ref)
    }
    
    mutating func changeReference(book: Book, chapter: Int) {
        let curr = self.current()
        let ref = Reference(bibleId: curr.bibleId, bookId: book.bookId, bookName: book.name,
                            chapter: chapter, verse: 1)
        self.add(reference: ref)
    }
    
    mutating func changeReference(reference: Reference) {
        let curr = self.current()
        if reference.bibleId != curr.bibleId {
            self.tableContents = TableContentsModel(bible: curr.bible)
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
