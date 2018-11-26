//
//  NotesModel.swift
//  Settings
//
//  Created by Gary Griswold on 11/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import Foundation

struct Note {
    var bookId: String
    var chapter: Int            // 0 means any chapter in book
    var datetime: TimeInterval  // Last update time
    var verseStart: Int         // 0 means any verse in chapter
    var verseEnd: Int           // 0 means any verse in chapter
    var bibleId: String         // 0 means any version
    var selection: String
    var bookmark: Bool
    var highlightColor: String? // color name in HEX, presence indicates highlight
    var note: String?
/*
    init(bookId: String, chapter: Int, verse: Int, bibleId: String, bookmark: Bool,
         highlightColor: String?, selection: String, note: String?) {
        self.bookId = bookId
        self.chapter = chapter
        self.datetime = Date().timeIntervalSince1970
        self.verseStart = verse
        self.verseEnd = verse
        self.bibleId = "0"
        self.bookmark = true
        self.highlightColor = highlightColor
        self.selection = selection
        self.note = note
    }
    
    init(bookId: String, chapter: Int, verse: Int) {
        self.bookId = bookId
        self.chapter = chapter
        self.datetime = Date().timeIntervalSince1970
        self.verseStart = verse
        self.verseEnd = verse
        self.bibleId = "0"
        self.bookmark = true
        self.highlightColor = nil
        self.selection = "" // OK?
        self.note = nil
    }
*/
    static let installEffect = "function installEffect(range, type, color) {\n"
        + "  var startNode = range.startContainer;\n"
        + "  if (type === 'book') {\n"
        + "    var book = document.createElement('span');\n"
        + "    book.innerHTML = '&#x1F516; ';\n"
        + "    startNode.parentNode.insertBefore(book, startNode);\n"
        + "  } else if (type === 'note') {\n"
        + "    var note = document.createElement('span');\n"
        + "    note.innerHTML = '&#x1F5D2; ';\n"
        + "    startNode.parentNode.insertBefore(note, startNode);\n"
        + "  } else if (type === 'lite') {\n"
        + "    document.designMode = 'on';\n"
        + "    document.execCommand('HiliteColor', false, color);\n"
        + "    document.designMode = 'off';\n"
        + "  } else {\n"
        + "    throw 'type \"' + type + '\" is not known.';\n"
        + "  }\n"
        + "}\n"
    
    static let encodeRange = "function encodeRange(range) {\n"
        + "  var startNode = range.startContainer;\n"
        + "  var endNode = range.endContainer;\n"
        + "  var startId = identElement(startNode);\n"
        + "  var endId = identElement(endNode);\n"
        + "  var startChars = range.startOffset + adjustStartChar(startNode);\n"
        + "  var endChars = range.endOffset + adjustStartChar(endNode);\n"
        + "  return startId + ':' + startChars + '/' + endId + ':' + endChars;\n"
        + "}\n"
        + "function identElement(node) {\n"
        + "  var element = node.parentNode;\n"
        + "  var clas = element.className;\n"
        + "  var list = document.getElementsByClassName(clas);\n"
        + "  for (var i=0; i<list.length; i++) {\n"
        + "    var item = list[i];\n"
        + "    if (item === element) {\n"
        + "      return(clas + ':' + i);\n"
        + "    }\n"
        + "  }\n"
        + "  return null;\n"
        + "}\n"
        + "function adjustStartChar(node) {\n"
        + "  var countChars = 0;\n"
        + "  var element = node.parentNode;\n"
        + "  if (element.hasChildNodes()) {\n"
        + "    for (var i=0; i<element.childNodes.length; i++) {"
        + "      var child = element.childNodes[i];\n"
        + "      if (child !== node) {\n"
        + "        countChars += child.textContent.length;\n"
        + "      } else {\n"
        + "        return countChars;\n"
        + "      }\n"
        + "    }\n"
        + "  }\n"
        + "  return countChars;\n"
        + "}\n"
    
    static let decodeRange = "function decodeRange(string) {"
    
    //    return range
    //}"
}

struct NotesModel {
    
 /*
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
        let notes = SettingsDB.shared.getNotes(bookId: "JHN", chapter: 0, bibleId: "0")
        //8. view results with print
        print("NOTES \(notes)")
        //9. queryDB for one
        let notes1 = SettingsDB.shared.getNotes(bookId: "JHN", chapter: 3, bibleId: "ENGWEB")
        //10. view results with print
        print("NOTE \(notes1)")
    }*/
}
