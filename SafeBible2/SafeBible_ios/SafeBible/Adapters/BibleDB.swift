//
//  BibleDB.swift
//  Settings
//
//  Created by Gary Griswold on 10/20/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct BibleDB {
    
    static var shared = BibleDB()
    
    private init() {}
    
    func getTableContents(bibleId: String) -> [Book] {
        let db: Sqlite3
        var toc = [Book]()
        do {
            db = try self.getBibleDB(bibleId: bibleId)
            let sql = "SELECT code, name, lastChapter FROM TableContents ORDER BY rowid"
            let resultSet = try db.queryV1(sql: sql, values: [])
            for index in 0..<resultSet.count {
                let row = resultSet[index]
                toc.append(Book(bookId: row[0]!, ordinal: index, name: row[1]!,
                                lastChapter: Int(row[2]!) ?? 0))
            }
            return toc
        } catch let err {
            print("ERROR BibleDB.getTableContents \(err)")
            return []
        }
    }
    
    func storeTableContents(bibleId: String, books: [Book]) {
        DispatchQueue.main.async(execute: {
            let db: Sqlite3
            var values = [[Any]]()
            for book in books {
                values.append([book.bookId, (book.ordinal + 1), book.name, book.lastChapter])
            }
            do {
                db = try self.getBibleDB(bibleId: bibleId)
                let sql = "REPLACE INTO TableContents (code, rowid, name, lastChapter)"
                    + " VALUES (?,?,?,?)"
                _ = try db.bulkExecuteV1(sql: sql, values: values)
            } catch let err {
                print("ERROR BibleDB.storeTableContents \(err)")
            }
        })
    }
    
    func getBiblePage(reference: Reference) -> String? {
        let db: Sqlite3
        do {
            db = try self.getBibleDB(bibleId: reference.bibleId)
            let sql = "SELECT html FROM Chapters WHERE reference = ?"
            let resultSet = try db.queryHTMLv0(sql: sql, values: [reference.nodeId()])
            return (resultSet.count > 0) ? resultSet : nil
        } catch let err {
            print("ERROR BibleDB.getBiblePage \(err)")
            return nil
        }
    }
    
    func storeBiblePage(reference: Reference, html: String) {
        DispatchQueue.main.async(execute: {
            let db: Sqlite3
            let values: [Any] = [reference.nodeId(), html]
            do {
                db = try self.getBibleDB(bibleId: reference.bibleId)
                let sql = "REPLACE INTO Chapters (reference, html) VALUES (?,?)"
                _ = try db.executeV1(sql: sql, values: values)
            } catch let err {
                print("ERROR BibleDB.storeBiblePage \(err)")
            }
        })
    }
    
    private func getBibleDB(bibleId: String) throws -> Sqlite3 {
        var db: Sqlite3?
        do {
            db = try Sqlite3.findDB(dbname: bibleId)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: bibleId, copyIfAbsent: false) // No more embedded Bibles
            let create1 = "CREATE TABLE IF NOT EXISTS TableContents("
                + " code TEXT PRIMARY KEY NOT NULL,"
                + " name TEXT NOT NULL,"
                + " lastChapter INT NOT NULL)"
            _ = try db?.executeV1(sql: create1, values: [])
            let create2 = "CREATE TABLE IF NOT EXISTS Chapters("
                + " reference TEXT NOT NULL PRIMARY KEY,"
                + " html TEXT NOT NULL)"
            _ = try db?.executeV1(sql: create2, values: [])
        }
        return db!
    }
}
