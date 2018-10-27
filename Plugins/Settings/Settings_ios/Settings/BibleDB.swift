//
//  BibleDB.swift
//  Settings
//
//  Created by Gary Griswold on 10/20/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct BibleDB {
    
    let bible: Bible
    let dbname: String
    
    init(bible: Bible) {
        self.bible = bible
        self.dbname = bible.bibleId + ".db"
    }
    
    func getTableContents() -> [Book] {
        let db: Sqlite3
        do {
            db = try self.getBibleDB()
            let sql = "SELECT bookId, ordinal, name, lastChapter FROM TableContents ORDER BY ordinal"
            let resultSet = try db.queryV1(sql: sql, values: [])
            let toc = resultSet.map {
                Book(bookId: $0[0]!, ordinal: Int($0[1]!) ?? 0, name: $0[2]!, lastChapter: Int($0[3]!) ?? 1)
            }
            return toc
        } catch let err {
            print("ERROR BibleDB.getTableContents \(err)")
            return []
        }
    }
    
    func storeTableContents(books: [Book]) {
        DispatchQueue.main.async(execute: {
            let db: Sqlite3
            var values = [[Any]]()
            for book in books {
                values.append([book.bookId, book.ordinal, book.name, book.lastChapter])
            }
            do {
                db = try self.getBibleDB()
                let sql = "REPLACE INTO TableContents (bookId, ordinal, name, lastChapter) VALUES (?,?,?,?)"
                _ = try db.bulkExecuteV1(sql: sql, values: values)
            } catch let err {
                print("ERROR BibleDB.storeTableContents \(err)")
            }
        })
    }
    
    func getBiblePage(reference: Reference) -> String? {
        let db: Sqlite3
        do {
            db = try self.getBibleDB()
            let sql = "SELECT html FROM Chapters WHERE bookId = ? AND chapter = ?"
            let resultSet = try db.queryHTMLv0(sql: sql, values: [reference.bookId, reference.chapter])
            return (resultSet.count > 0) ? resultSet : nil
        } catch let err {
            print("ERROR BibleDB.getBiblePage \(err)")
            return nil
        }
    }
    
    func storeBiblePage(html: String, reference: Reference) {
        DispatchQueue.main.async(execute: {
            let db: Sqlite3
            let values: [Any] = [reference.bookId, reference.chapter, html]
            do {
                db = try self.getBibleDB()
                let sql = "REPLACE INTO Chapters (bookId, chapter, html) VALUES (?,?,?)"
                _ = try db.executeV1(sql: sql, values: values)
            } catch let err {
                print("ERROR BibleDB.storeTableContents \(err)")
            }
        })
    }
    
    private func getBibleDB() throws -> Sqlite3 {
        var db: Sqlite3?
        do {
            db = try Sqlite3.findDB(dbname: self.dbname)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: dbname, copyIfAbsent: false) // No more embedded Bibles
            let create1 = "CREATE TABLE IF NOT EXISTS TableContents(" +
                " bookId TEXT PRIMARY KEY NOT NULL," +
                " ordinal INT NOT NULL," +
                " name TEXT NOT NULL," +
                " lastChapter INT NOT NULL)"
            _ = try db?.executeV1(sql: create1, values: [])
            let create2 = "CREATE TABLE IF NOT EXISTS Chapters(" +
                " bookId TEXT NOT NULL," +
                " chapter INT NOT NULL," +
                " html TEXT NOT NULL," +
                " PRIMARY KEY (bookId, chapter))"
            _ = try db?.executeV1(sql: create2, values: [])
        }
        return db!
    }
}
