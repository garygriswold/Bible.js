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
            let bibl1 = Reference.bibleMap[self.bibleId]
            if bibl1 != nil { return bibl1! }
            var bibl2 = VersionsDB.shared.getBible(bibleId: self.bibleId)
            bibl2.tableContents = TableContentsModel(bible: bibl2)
            Reference.bibleMap[self.bibleId] = bibl2
            return bibl2
        }
    }
    
    func description() -> String {
        return "\(self.bookName) \(self.chapter):\(self.verse)"
    }
    
    func toString() -> String {
        return "\(self.bibleId) \(self.bookId):\(self.chapter):\(self.verse)"
    }
}
