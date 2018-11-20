//
//  NotesModel.swift
//  Settings
//
//  Created by Gary Griswold on 11/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

struct Note {
    var bookId: String
    var chapter: Int            // 0 means any chapter in book
    var verse: Int              // 0 means any verse in chapter
    var bibleId: String         // 0 means any version
    var bookmark: Bool
    var highlightColor: String? // color name, presence indicates highlight
    var startChar: Int?         // optional for highlight
    var endChar: Int?           // optional for highlight
    var note: String?
    
    init(bookId: String, chapter: Int, verse: Int, bibleId: String, bookmark: Bool,
         highlightColor: String?, startChar: Int?, endChar: Int?, note: String?) {
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.bibleId = "0"
        self.bookmark = true
        self.highlightColor = highlightColor
        self.startChar = startChar
        self.endChar = endChar
        self.note = note
    }
    
    init(bookId: String, chapter: Int, verse: Int) {
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.bibleId = "0"
        self.bookmark = true
        self.highlightColor = nil
        self.startChar = nil
        self.endChar = nil
        self.note = nil
    }
}

struct NotesModel {
    
    
    static func unitTest() {
        //1. init a note object with all none null values
        let note1 = Note(bookId: "JHN", chapter: 3, verse: 3, bibleId: "ENGWEB", bookmark: true,
                         highlightColor: "green", startChar: 12, endChar: 24,
                         note: "It was a dark and stormy night")
        //2. store using SettingsDB
        SettingsDB.shared.storeNote(note: note1)
        //3. inspect DB
        //4. init a note object with mostly null objects
        let note2 = Note(bookId: "JHN", chapter: 0, verse: 0, bibleId: "0", bookmark: false,
                         highlightColor: nil, startChar: nil, endChar: nil,
                         note: nil)
        //5. store using SettingsDB
        SettingsDB.shared.storeNote(note: note2)
        //6. inspect DB
        //7. queryDB for all
        let notes = SettingsDB.shared.getNotes(bookId: "JHN", chapter: 0, verse: 0, bibleId: "0")
        //8. view results with print
        print("NOTES \(notes)")
        //9. queryDB for one
        let notes1 = SettingsDB.shared.getNotes(bookId: "JHN", chapter: 3, verse: 3, bibleId: "ENGWEB")
        //10. view results with print
        print("NOTE \(notes1)")
    }
}
