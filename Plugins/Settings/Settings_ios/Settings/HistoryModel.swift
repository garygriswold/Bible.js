//
//  HistoryModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/18/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct History : Equatable {
    let bibleId: String
    let bookId: String
    let chapter: Int
    let verse: Int
    
    static func == (lhs: History, rhs: History) -> Bool {
        return lhs.bibleId == rhs.bibleId
    }
    
    func toString() -> String {
        return "\(self.bookId) \(self.bookId):\(self.chapter):\(self.verse)"
    }
}

struct HistoryModel {
    
    private var history = [History]()
    private var index = 0
    
    init() {
        self.history = self.getHistory()
        self.index = self.history.count - 1
        if self.index < 0 {
            self.history.append(History(bibleId: "ENGESV", bookId: "JHN", chapter: 3, verse: 1))
            self.index = 0
            self.storeHistory(history: self.history[0])
        }
    }
    
    mutating func add(history: History) {
        self.history.append(history)
        self.index += 1
        self.storeHistory(history: history)
    }
    
    mutating func add(bibleId: String, bookId: String, chapter: Int, verse: Int) {
        self.add(history: History(bibleId: bibleId, bookId: bookId, chapter: chapter, verse: verse))
    }
    
    mutating func add(bookId: String, chapter: Int, verse: Int) {
        if let top = self.history.last {
            self.add(history: History(bibleId: top.bookId, bookId: bookId, chapter: chapter, verse: verse))
        } else {
            fatalError("Unable to add history, because empty")
        }
    }
    
    mutating func add(chapter: Int, verse: Int) {
        if let top = self.history.last {
            self.add(history: History(bibleId: top.bookId, bookId: top.bookId, chapter: chapter,
                                      verse: verse))
        } else {
            fatalError("Unable to add history, because empty")
        }
    }
    
    func current() -> History {
        return self.history[self.index]
    }
    
    mutating func back() -> History? {
        self.index -= 1
        return (self.index >= 0 && self.index < self.history.count) ? self.history[self.index] : nil
    }
    
    mutating func forward() -> History? {
        self.index += 1
        return (self.index >= 0 && self.index < self.history.count) ? self.history[self.index] : nil
    }
    
    private func getHistory() -> [History] {
        let db: Sqlite3
        do {
            db = try getSettingsDB()
            let sql = "SELECT bibleId, bookId, chapter, verse FROM History ORDER BY datetime desc limit 100"
            let resultSet = try db.queryV1(sql: sql, values: [])
            let history = resultSet.map {
                History(bibleId: $0[0]!, bookId: $0[1]!,
                        chapter: Int($0[2]!) ?? 1,
                        verse: Int($0[3]!) ?? 1)
            }
            return history
        } catch {
           return []
        }
    }
    
    private func storeHistory(history: History) {
        let db: Sqlite3
        do {
            db = try getSettingsDB()
            let sql = "INSERT INTO History (bibleId, bookId, chapter, verses, datetime) VALUES (?,?,?,?,?)"
            let datetime = Date().description
            let values: [Any] = [history.bibleId, history.bookId, history.chapter, history.verse, datetime]
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
                        " bibleId TEXT PRIMARY KEY NOT NULL," +
                        " bookId TEXT NOT NULL," +
                        " chapter INT NOT NULL," +
                        " verse INT NOT NULL," +
                        " datetime TEXT NOT NULL)"
            _ = try db?.executeV1(sql: create, values: [])
        }
        return db!
    }
}
