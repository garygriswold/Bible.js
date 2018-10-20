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
    
    private var history = [Reference]()
    private var index = 0
    
    init() {
        self.history = self.getHistory()
        self.index = self.history.count - 1
        if self.index < 0 {
            self.history.append(Reference(bibleId: "ENGESV", abbr: "ESV", bookId: "JHN",
                                          chapter: 3, verse: 1))
            self.index = 0
            self.storeHistory(reference: self.history[0])
        }
    }
    
    mutating func add(reference: Reference) {
        self.history.append(reference)
        self.index += 1
        self.storeHistory(reference: reference)
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
    
    private func getHistory() -> [Reference] {
        let db: Sqlite3
        do {
            db = try getSettingsDB()
            let sql = "SELECT bibleId, abbr, bookId, chapter, verse FROM History ORDER BY datetime desc limit 100"
            let resultSet = try db.queryV1(sql: sql, values: [])
            let history = resultSet.map {
                Reference(bibleId: $0[0]!, abbr: $0[1]!, bookId: $0[2]!,
                        chapter: Int($0[3]!) ?? 1,
                        verse: Int($0[4]!) ?? 1)
            }
            return history
        } catch {
           return []
        }
    }
    
    private func storeHistory(reference: Reference) {
        let db: Sqlite3
        do {
            db = try getSettingsDB()
            let sql = "INSERT INTO History (bibleId, abbr, bookId, chapter, verse, datetime) VALUES (?,?,?,?,?,?)"
            let datetime = Date().description
            let values: [Any] = [reference.bibleId, reference.abbr, reference.bookId, reference.chapter,
                                 reference.verse, datetime]
            _ = try db.executeV1(sql: sql, values: values)
        } catch {
    
        }
    }
    
    private func getSettingsDB() throws -> Sqlite3 {
        var db: Sqlite3?
        let dbname = "Settings.db"
        do {
            db = try Sqlite3.findDB(dbname: dbname)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: dbname, copyIfAbsent: false)
            let create = "CREATE TABLE IF NOT EXISTS History(" +
                        " bibleId TEXT NOT NULL," +
                        " abbr TEXT NOT NULL," +
                        " bookId TEXT NOT NULL," +
                        " chapter INT NOT NULL," +
                        " verse INT NOT NULL," +
                        " datetime TEXT NOT NULL)"
            _ = try db?.executeV1(sql: create, values: [])
        }
        return db!
    }
}
