//
//  HTMLVerseParserTest.swift
//  SafeBible
//
//  Created by Gary Griswold on 3/9/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import Utility

class HTMLVerseParserTest {
    
    static func test() {
        let test = HTMLVerseParserTest()
        let dummyRef = Reference(bibleId: "ERV-ARB.db", bookId: "GEN", chapter: 1)
        test.bible = dummyRef.bible
        test.findVerseCount(bibleId: "ERV-ENG.db")
        test.populateChapters(bibleId: test.bible.bibleId)
        test.iterateChapters()
    }
    
    private var bible: Bible!
    private var verseCount = [String: Int]()
    private var references = [Reference]()
    private let page = BiblePageModel()
    
    private func findVerseCount(bibleId: String) {
        do {
            let db = try Sqlite3.openDB(dbname: bibleId, copyIfAbsent: true)
            let sql = "SELECT reference FROM Verses"
            let resultSet = try db.queryV1(sql: sql, values: [])
            for row in resultSet {
                let parts = row[0]!.split(separator: ":")
                let chapter = String(parts[0]) + ":" + String(parts[1])
                let verse = Int(parts[2].split(separator: "-")[0])!
                let currVerse = verseCount[chapter]
                if currVerse == nil || currVerse! < verse {
                    verseCount[chapter] = verse
                }
            }
        } catch let err {
            print("ERROR: HTMLVerseParserTest.findVerseCount \(err)")
        }
        //print(verseCount)
    }
    
    private func populateChapters(bibleId: String) {
        let endRef = Reference(bibleId: bibleId, bookId: "REV", chapter: 22)
        var ref = Reference(bibleId: bibleId, bookId: "MAT", chapter: 1)
        while(ref != endRef) {
            self.references.append(ref)
            ref = ref.nextChapter()
        }
        //print(self.references)
    }
    
    private func iterateChapters() {
        let ref = self.references.popLast()
        if ref != nil {
            if let lastVerse = self.verseCount[ref!.nodeId()] {
                self.page.testParse(reference: ref!, lastVerse: lastVerse, complete: {
                    self.iterateChapters()
                })
            } else {
                print("NO LAST VERSE FOR \(ref!)")
                self.iterateChapters()
            }
        }
    }
}
