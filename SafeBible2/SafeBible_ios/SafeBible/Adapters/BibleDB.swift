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
    
    func getTableContents(bible: Bible) -> [Book] {
        let db: Sqlite3
        var toc = [Book]()
        do {
            db = try self.getBibleDB(bible: bible)
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
    
    func storeTableContents(bible: Bible, books: [Book]) {
        DispatchQueue.main.async(execute: {
            let db: Sqlite3
            var values = [[Any]]()
            for book in books {
                values.append([book.bookId, (book.ordinal + 1), book.name, book.lastChapter])
            }
            do {
                db = try self.getBibleDB(bible: bible)
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
            db = try self.getBibleDB(bible: reference.bible)
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
                db = try self.getBibleDB(bible: reference.bible)
                let sql = "REPLACE INTO Chapters (reference, html) VALUES (?,?)"
                _ = try db.executeV1(sql: sql, values: values)
            } catch let err {
                print("ERROR BibleDB.storeBiblePage \(err)")
            }
        })
    }
    
    func getBibleVerses(reference: Reference, startVerse: Int, endVerse: Int) -> String {
        var result = [String]()
        let db: Sqlite3
        do {
            db = try self.getBibleDB(bible: reference.bible)
            for verse in startVerse...endVerse {
                print("Verse = \(verse)")
                let sql = "SELECT html FROM Verses WHERE reference = ?"
                let resultSet = try db.queryV1(sql: sql, values: [reference.nodeId(verse: verse)])
                if resultSet.count > 0 {
                    result.append(resultSet[0][0] ?? "")
                }
            }
        } catch let err {
            print("ERROR getBibleVerses \(err)")
        }
        return result.joined(separator: "\n")
    }
    
    func isDownloadedTest(bible: Bible) -> Bool {
        let db: Sqlite3
        do {
            db = try self.getBibleDB(bible: bible)
            let sql = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name IN"
                + " ('verses', 'concordance')"
            let resultSet = try db.queryV1(sql: sql, values: [])
            let count: Int = Int(resultSet[0][0]!) ?? 0
            return (count == 2)
        } catch let err {
            print("ERROR isDownloadedTest \(err)")
            return false
        }
    }
    
    func shouldDownload(bible: Bible) -> Bool {
        let db: Sqlite3
        do {
            db = try self.getBibleDB(bible: bible)
            let sql = "SELECT count(*) FROM Chapters"
            let resultSet = try db.queryV1(sql: sql, values: [])
            let count: Int = Int(resultSet[0][0]!) ?? 0
            return (count > 20) // Should download if more than 20 chapters read.
        } catch let err {
            print("ERROR shouldDownloadTest \(err)")
            return false
        }
    }
    
    //
    // Concordance Table
    //

    /**
     * This is similar to select, except that it returns the refList2 field,
     * and resequences the results into the order the words were entered.
     */
    func selectRefList2(bible: Bible, words: [String]) -> [[String]] {
        let values = words.map { $0.lowercased() }
        let db: Sqlite3
        do {
            let sql = "SELECT word, refList2 FROM concordance WHERE word IN" + self.genQuest(array: words)
            db = try self.getBibleDB(bible: bible)
            let resultSet = try db.queryV1(sql: sql, values: values)
            var resultMap = [String: [String]]()
            for row in resultSet {
               resultMap[row[0]!] = row[1]!.components(separatedBy: ",")
            }
            // This sequences the returned arrays into the order of the words
            var refLists = [[String]]()
            for word in words {
                if let result = resultMap[word] {
                    refLists.append(result)
                }
            }
            return refLists
        } catch let err {
            print("ERROR selectRefList2 \(err)")
            return [[String]]()
        }
    }

    private func getBibleDB(bible: Bible) throws -> Sqlite3 {
        var db: Sqlite3?
        do {
            db = try Sqlite3.findDB(dbname: bible.bibleId)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: bible.bibleId, copyIfAbsent: false) // No more embedded Bibles
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
    
    private func genQuest(array: [Any]) -> String {
        let quest = [String](repeating: "?", count: array.count)
        return " (" + quest.joined(separator: ",") + ")"
    }
}
