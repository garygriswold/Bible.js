//
//  Reference.swift
//  Settings
//
//  Created by Gary Griswold on 10/28/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

struct Reference : Equatable {
    
    private static var bibleMap = [String:Bible]()
    
    let bibleId: String
    let bookId: String
    let chapter: Int
    let verse: Int?
    
    init(bibleId: String, bookId: String, chapter: Int, verse: Int?) {
        self.bibleId = bibleId
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
    }
    
    init(bibleId: String, bookId: String, chapter: Int) {
        self.bibleId = bibleId
        self.bookId = bookId
        self.chapter = chapter
        self.verse = nil
    }
    
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
    
    var s3TextPrefix: String {
        get { return self.bible.s3TextPrefix }
    }
    
    var s3TextTemplate: String {
        get { return self.bible.s3TextTemplate }
    }
    
    var bible: Bible {
        get {
            let bibl1 = Reference.bibleMap[self.bibleId]
            if bibl1 != nil { return bibl1! }
            var bibl2 = VersionsDB.shared.getBible(bibleId: self.bibleId)
            bibl2.tableContents = TableContentsModel(bible: bibl2)
            Reference.bibleMap[self.bibleId] = bibl2
            return bibl2
        }
    }
    
    var bookName: String {
        get {
            if let book = self.book {
                return book.name
            } else {
                return self.bookId
            }
        }
    }
    
    var book: Book? { // Will return null if TOC has not yet arrived from AWS
        get { return self.bible.tableContents!.getBook(bookId: self.bookId) }
    }
    
    func nextChapter() -> Reference {
        return self.bible.tableContents!.nextChapter(reference: self)
    }
    
    func priorChapter() -> Reference {
        return self.bible.tableContents!.priorChapter(reference: self)
    }
    
    func description() -> String {
        if self.verse != nil {
            return "\(self.bookName) \(self.chapter):\(self.verse!)"
        } else {
            return "\(self.bookName) \(self.chapter)"
        }
    }
    
    func description(startVerse: Int, endVerse: Int) -> String {
        let verse = (startVerse != endVerse) ? "\(startVerse)-\(endVerse)" : String(startVerse)
        return self.description() + ":" + verse
    }
    
    func toString() -> String {
        if self.verse != nil {
            return "\(self.bibleId) \(self.bookId):\(self.chapter):\(self.verse!)"
        } else {
            return "\(self.bibleId) \(self.bookId):\(self.chapter)"
        }
    }
}
