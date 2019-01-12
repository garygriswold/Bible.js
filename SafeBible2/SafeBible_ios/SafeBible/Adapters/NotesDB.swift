//
//  NotesDB.swift
//  Settings
//
//  Created by Gary Griswold on 12/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct NotesDB {
    
    static var shared = NotesDB()
    
    private var _currentDB: String = "Notes"
    var currentDB: String {
        get { return _currentDB }
        set {
            Sqlite3.closeDB(dbname: _currentDB)
            _currentDB = newValue
        }
    }
    
    private init() {}
    
    func getNotes(bookId: String?, note: Bool, lite: Bool, book: Bool) -> [Note] {
        let db: Sqlite3
        do {
            db = try self.getNotesDB()
            var sql = "SELECT noteId, Notes.bookId, chapter, datetime, startVerse, endVerse, bibleId,"
                + " selection, classes, bookmark, highlight, note"
                + " FROM Notes JOIN BookSeq ON Notes.bookId = BookSeq.bookId"
            var values: [String] = []
            var orPredicates = [String]()
            if note {
                orPredicates.append("note is not NULL")
            }
            if lite {
                orPredicates.append("highlight is not NULL")
            }
            if book {
                orPredicates.append("bookmark = 'T'")
            }
            if orPredicates.count > 0 {
                sql += " WHERE (" + orPredicates.joined(separator: " OR ") + ")"
            } else {
                sql += " WHERE 1=2"
            }
            if bookId != nil {
                sql += " AND Notes.bookId = ?"
                values = [bookId!]
            }
            sql += " ORDER BY sequence, chapter, startVerse"
            let resultSet = try db.queryV1(sql: sql, values: values)
            let notes = resultSet.map {
                Note(noteId: $0[0]!, bookId: $0[1]!, chapter: Int($0[2]!)!, datetime: Int($0[3]!)!,
                     startVerse: Int($0[4]!)!, endVerse: Int($0[5]!)!, bibleId: $0[6]!,
                     selection: $0[7]!, classes: $0[8]!, bookmark: $0[9] == "T", highlight: $0[10],
                     note: $0[11])
            }
            return notes
        } catch let err {
            print("ERROR NotesDB.getNotes() \(err)")
            return []
        }
    }
    
    func getNotes(bookId: String, chapter: Int) -> [Note] {
        let db: Sqlite3
        do {
            db = try self.getNotesDB()
            let sql = "SELECT noteId, datetime, startVerse, endVerse, bibleId, selection, classes, bookmark, highlight, note"
                + " FROM Notes"
                + " WHERE bookId = ?"
                + " AND chapter = ?"
                + " ORDER BY datetime ASC"
            let values: [Any] = [bookId, chapter]
            let resultSet = try db.queryV1(sql: sql, values: values)
            let notes = resultSet.map {
                Note(noteId: $0[0]!, bookId: bookId, chapter: chapter, datetime: Int($0[1]!)!,
                     startVerse: Int($0[2]!)!, endVerse: Int($0[3]!)!, bibleId: $0[4]!,
                     selection: $0[5]!, classes: $0[6]!, bookmark: $0[7] == "T", highlight: $0[8], note: $0[9])
            }
            return notes
        } catch let err {
            print("ERROR NotesDB.getNotes \(err)")
            return []
        }
    }
    
    func getNote(noteId: String) -> Note? {
        let db: Sqlite3
        do {
            db = try self.getNotesDB()
            let sql = "SELECT bookId, chapter, datetime, startVerse, endVerse, bibleId, selection, classes, bookmark, highlight, note"
                + " FROM Notes"
                + " WHERE noteId = ?"
            let values: [Any] = [noteId]
            let resultSet = try db.queryV1(sql: sql, values: values)
            let notes = resultSet.map {
                Note(noteId: noteId, bookId: $0[0]!, chapter: Int($0[1]!)!, datetime: Int($0[2]!)!,
                     startVerse: Int($0[3]!)!, endVerse: Int($0[4]!)!, bibleId: $0[5]!,
                     selection: $0[6]!, classes: $0[7]!, bookmark: $0[8] == "T", highlight: $0[9], note: $0[10])
            }
            return (notes.count > 0) ? notes[0] : nil
        } catch let err {
            print("ERROR NotesDB.getNote \(err)")
            return nil
        }
    }
    
    func storeNote(note: Note) {
        let db: Sqlite3
        do {
            db = try self.getNotesDB()
            let sql = "REPLACE INTO Notes (noteId, bookId, chapter, datetime, startVerse, endVerse, bibleId," +
                " selection, classes, bookmark, highlight, note) VALUES" +
            " (?,?,?,?,?,?,?,?,?,?,?,?)"
            var values = [Any?]()
            values.append(note.noteId)
            values.append(note.bookId)
            values.append(note.chapter)
            values.append(note.datetime)
            values.append(note.startVerse)
            values.append(note.endVerse)
            values.append(note.bibleId)
            values.append(note.selection)
            values.append(note.classes)
            values.append(note.bookmark)
            values.append(note.highlight)
            values.append(note.note)
            _ = try db.executeV1(sql: sql, values: values)
        } catch let err {
            print("ERROR NotesDB.storeNote \(err)")
        }
    }
    
    func deleteNote(noteId: String) {
        let db: Sqlite3
        do {
            db = try self.getNotesDB()
            let sql = "DELETE FROM Notes WHERE noteId = ?"
            let values = [noteId]
            _ = try db.executeV1(sql: sql, values: values)
        } catch let err {
            print("ERROR NotesDB.deleteNote \(err)")
        }
    }
    
    /**
    * This took 145ms with only one row.  The method below did not perform any better.
    * Test again with more data.
    */
    func copyBookNotes(url: URL, bookId: String) {
        let measure = Measurement()
        do {
            // open target database
            let files = FileManager.default
            let path = url.path
            if files.fileExists(atPath: path) {
                try files.removeItem(atPath: path)
            }
            //measure.duration(location: "delete prior database")
            let target = Sqlite3()
            try target.openLocal(path: path)
            //measure.duration(location: "open new database")
            try self.createNotesTable(db: target)
            try self.createBookSeq(db: target)
            //measure.duration(location: "create new table")
            
            let db: Sqlite3
            db = try self.getNotesDB()
            let select = "SELECT * from Notes WHERE bookId = ? AND note is not null"
            let resultSet = try db.queryV1(sql: select, values: [bookId])
            //measure.duration(location: "select notes")

            let insert = "INSERT INTO Notes VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"
            _ = try target.bulkExecuteV1(sql: insert, values: resultSet)
            //measure.duration(location: "insert notes")
            target.close()
            measure.duration(location: "close target database")
        } catch let err {
            print("ERROR: NotesDB.copyBookNotes \(err)")
        }
    }
    /*
    * This was an attempt to improve performance, but it did not.  It also has the disadvantage
    * that the final Notes table does not have constraints and indexes, but try again with more data.
    */
    func copyBookNotes1(url: URL, bookId: String) {
        let measure = Measurement()
        do {
            // copy database to target database
            let files = FileManager.default
            let path = url.path
            if files.fileExists(atPath: path) {
                try files.removeItem(atPath: path)
            }
            measure.duration(location: "remove prior temp database")
            let source = Sqlite3.pathDB(dbname: "Notes.notes")
            try files.copyItem(at: source, to: url)
            measure.duration(location: "copy full database")
            
            // Select rows and delete original table
            let target = Sqlite3()
            try target.openLocal(path: path)
            measure.duration(location: "open target database")
            let sql = "CREATE TABLE Notes_new AS SELECT * FROM Notes WHERE bookId = ? AND note is not null"
            let count = try target.executeV1(sql: sql, values: [bookId])
            measure.duration(location: "create selected table")
            print("CopyBookNotes \(count) rows copied)")
            let drop = "DROP TABLE Notes"
            _ = try target.executeV1(sql: drop, values: [])
            measure.duration(location: "drop old notes")
            let rename = "ALTER TABLE Notes_new RENAME TO Notes"
            _ = try target.executeV1(sql: rename, values: [])
            measure.duration(location: "rename new notes")
            _ = try target.executeV1(sql: "vacuum", values: [])
            measure.duration(location: "vacuum")
        } catch let err {
            print("ERROR: NotesDB.copyBookNotes \(err)")
        }
    }
    
    func importDB(source: URL, dbname: String) -> String? {
        let files = FileManager.default
        let dbDir = self.getDirectory()
        var target: URL = URL(fileURLWithPath: dbname + ".notes", relativeTo: dbDir)
        do {
            if files.fileExists(atPath: target.path) {
                target = findAvailable(url: target, directory: dbDir)
            }
            _ = source.startAccessingSecurityScopedResource()
            try files.copyItem(at: source, to: target)
            source.stopAccessingSecurityScopedResource()
            return String(target.lastPathComponent.split(separator: ".")[0])
        } catch let err {
            print("ERROR: Could not copy \(err)")
            return nil
        }
    }
    
    func pathDB(dbname: String) -> URL {
        return URL(fileURLWithPath: dbname + ".notes", relativeTo: getDirectory())
    }
    
    private func getDirectory() -> URL {
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        let dbDir: URL = libDir.appendingPathComponent("LocalDatabase")
        return dbDir
    }

    private func findAvailable(url: URL, directory: URL) -> URL {
        let filename = url.lastPathComponent.split(separator: ".")[0]
        var count = 1
        var resultURL = url
        while FileManager.default.fileExists(atPath: resultURL.path) {
            resultURL = URL(fileURLWithPath: "\(filename)-\(count).notes", relativeTo: directory)
            count += 1
        }
        return resultURL
    }
    
    func listDB() -> [String: URLResourceValues] {
        var results = [String: URLResourceValues]()
        let manager = FileManager.default
        let keys: [URLResourceKey] = [.nameKey, .pathKey, .creationDateKey, .contentModificationDateKey,
                                      .contentAccessDateKey, .addedToDirectoryDateKey]
        let keySet = Set(keys)
        do {
            let files = try manager.contentsOfDirectory(at: self.getDirectory(),
                includingPropertiesForKeys: keys, options: [])
            for file in files {
                if file.path.hasSuffix(".notes") {
                    let meta = try file.resourceValues(forKeys: keySet)
                    let name = String(meta.name!.split(separator: ".")[0])
                    results[name] = meta
               }
            }
        } catch let err {
            print("ERROR NotesDB.listDB \(err)")
        }
        return results
    }
    
    func renameDB(dbname: String, rename: String) {
        let source = URL(fileURLWithPath: dbname + ".notes", relativeTo: self.getDirectory())
        let target = URL(fileURLWithPath: rename + ".notes", relativeTo: self.getDirectory())
        do {
            try FileManager.default.moveItem(at: source, to: target)
        } catch let err {
            print("ERROR: NotesDB.renameDB \(err)")
        }
    }
    
    func deleteDB(dbname: String) {
        let url = URL(fileURLWithPath: dbname + ".notes", relativeTo: self.getDirectory())
        do {
            try FileManager.default.removeItem(at: url)
        } catch let err {
            print("ERROR: NotesDB.deleteDB \(err)")
        }
    }
    
    private func getNotesDB() throws -> Sqlite3 {
        var db: Sqlite3?
        let dbname = NotesDB.shared.currentDB + ".notes"
        do {
            db = try Sqlite3.findDB(dbname: dbname)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: dbname, copyIfAbsent: false)
            try self.createNotesTable(db: db!)
            try self.createBookSeq(db: db!)
        }
        return db!
    }
        
    private func createNotesTable(db: Sqlite3) throws {
        let create3 = "CREATE TABLE IF NOT EXISTS Notes("
            + " noteId TEXT PRIMARY KEY,"
            + " bookId TEXT NOT NULL,"
            + " chapter INT NOT NULL,"
            + " datetime INT NOT NULL,"
            + " startVerse INT NOT NULL,"
            + " endVerse INT NOT NULL,"
            + " bibleId TEXT NOT NULL,"
            + " selection TEXT NOT NULL,"
            + " classes TEXT NOT NULL,"
            + " bookmark TEXT check(bookmark IN ('T', 'F')),"
            + " highlight TEXT NULL,"
            + " note TEXT NULL)"
        _ = try db.executeV1(sql: create3, values: [])
        let create4 = "CREATE INDEX IF NOT EXISTS book_chapter_idx on Notes (bookId, chapter, datetime)"
        _ = try db.executeV1(sql: create4, values: [])
    }
    
    private func createBookSeq(db: Sqlite3) throws {
        if try db.objectExists(type: "table", name: "BookSeq") {
            return
        }
        let create = "CREATE TABLE BookSeq("
            + " bookId TEXT PRIMARY KEY,"
            + " sequence INT NOT NULL)"
        _ = try db.executeV1(sql: create, values: [])
        let insert = "INSERT INTO BookSeq (sequence, bookId) VALUES (?, ?)"
        let values = [[01,"GEN"],[02,"EXO"],[03,"LEV"],[04,"NUM"],[05,"DEU"],[06,"JOS"],[07,"JDG"],
                      [08,"RUT"],[09,"1SA"],[10,"2SA"],[11,"1KI"],[12,"2KI"],[13,"1CH"],[14,"2CH"],
                      [15,"EZR"],[16,"NEH"],[17,"EST"],[18,"JOB"],[19,"PSA"],[20,"PRO"],[21,"ECC"],
                      [22,"SNG"],[23,"ISA"],[24,"JER"],[25,"LAM"],[26,"EZK"],[27,"DAN"],[28,"HOS"],
                      [29,"JOL"],[30,"AMO"],[31,"OBA"],[32,"JON"],[33,"MIC"],[34,"NAM"],[35,"HAB"],
                      [36,"ZEP"],[37,"HAG"],[38,"ZEC"],[39,"MAL"],[41,"MAT"],[42,"MRK"],[43,"LUK"],
                      [44,"JHN"],[45,"ACT"],[46,"ROM"],[47,"1CO"],[48,"2CO"],[49,"GAL"],[50,"EPH"],
                      [51,"PHP"],[52,"COL"],[53,"1TH"],[54,"2TH"],[55,"1TI"],[56,"2TI"],[57,"TIT"],
                      [58,"PHM"],[59,"HEB"],[60,"JAS"],[61,"1PE"],[62,"2PE"],[63,"1JN"],[64,"2JN"],
                      [65,"3JN"],[66,"JUD"],[67,"REV"],[68,"TOB"],[69,"JDT"],[70,"ESG"],[71,"WIS"],
                      [72,"SIR"],[73,"BAR"],[74,"LJE"],[75,"S3Y"],[76,"SUS"],[77,"BEL"],[78,"1MA"],
                      [79,"2MA"],[80,"3MA"]]
        _ = try db.bulkExecuteV1(sql: insert, values: values)
    }
}
