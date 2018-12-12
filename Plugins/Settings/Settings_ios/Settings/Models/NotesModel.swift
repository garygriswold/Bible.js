//
//  NotesModel.swift
//  Settings
//
//  Created by Gary Griswold on 11/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import Foundation

struct Note {
    
    private static var regex1 = try! NSRegularExpression(pattern: "SPAN\\.v .+_(\\d+)\\/")
    private static var regex2 = try! NSRegularExpression(pattern: "SPAN\\.verse.*\\sv-(\\d+)\\/")
    
    let noteId: String
    let bookId: String
    let chapter: Int            // 0 means any chapter in book
    var datetime: Int           // Last update time
    var startVerse: Int         // 0 means any verse in chapter
    var endVerse: Int           // 0 means any verse in chapter
    var bibleId: String         // 0 means any version
    var selection: String
    var classes: String
    var bookmark: Bool
    var highlight: String?      // color name in HEX, presence indicates highlight
    var note: String?

    // Used to instantiate after user does selection
    init(bookId: String, chapter: Int, bibleId: String, selection: String, classes: String,
         bookmark: Bool, highlight: String?, note: String?) {
        self.noteId = UUID().uuidString
        self.bookId = bookId
        self.chapter = chapter
        self.datetime = Int(Date().timeIntervalSince1970)
        self.startVerse = 0
        self.endVerse = 0
        self.bibleId = bibleId
        self.selection = selection
        self.classes = classes
        self.bookmark = bookmark
        self.highlight = highlight
        self.note = note
        
        let parts = classes.split(separator: "~")
        self.startVerse = getVerseNum(classes: String(parts[0]))
        if parts.count > 0 {
            self.endVerse = getVerseNum(classes: String(parts[1]))
        }
        print("verse: \(self.startVerse) to \(self.endVerse)")
    }
    
    // Used to instantiate from selection from Notes table
    init(noteId: String, bookId: String, chapter: Int, datetime: Int, startVerse: Int, endVerse: Int, bibleId: String,
         selection: String, classes: String, bookmark: Bool, highlight: String?, note: String?) {
        self.noteId = noteId
        self.bookId = bookId
        self.chapter = chapter
        self.datetime = datetime
        self.startVerse = startVerse
        self.endVerse = endVerse
        self.bibleId = bibleId
        self.selection = selection
        self.classes = classes
        self.bookmark = bookmark
        self.highlight = highlight
        self.note = note
    }
    
    private func getVerseNum(classes: String) -> Int {
        var result = Note.regex1.matches(in: classes, range: NSMakeRange(0, classes.count))
        if result.count > 0 && result[0].numberOfRanges > 1 {
            return getSubstringInt(leaf: classes, result: result[0])
        } else {
            result = Note.regex2.matches(in: classes, range: NSMakeRange(0, classes.count))
            if result.count > 0 && result[0].numberOfRanges > 1 {
                return getSubstringInt(leaf: classes, result: result[0])
            }
        }
        return 0
    }
    
    private func getSubstringInt(leaf: String, result: NSTextCheckingResult) -> Int {
        let verse = result.range(at: 1)
        let start = leaf.index(leaf.startIndex, offsetBy: verse.location)
        let end = leaf.index(leaf.startIndex, offsetBy: verse.location + verse.length)
        let range = start..<end
        //print(leaf[range])
        return Int(leaf[range]) ?? 0
    }

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
        + "  } else if (type === 'lite_select') {\n"
        + "    document.designMode = 'on';\n"
        + "    document.execCommand('HiliteColor', false, color);\n"
        + "    document.designMode = 'off';\n"
        + "  } else if (type === 'lite_saved') {\n"
        + "    var select = window.getSelection();\n"
        + "    select.removeAllRanges();\n"
        + "    select.addRange(range);\n"
        + "    document.designMode = 'on';\n"
        + "    document.execCommand('HiliteColor', false, color);\n"
        + "    document.designMode = 'off';\n"
        + "    select.removeAllRanges();\n"
        + "  } else {\n"
        + "    throw 'type \"' + type + '\" is not known.';\n"
        + "  }\n"
        + "}\n"
    
    static let encodeRange = "function encodeRange(range) {\n"
        + "  var startPath = getXPathForNode(range.startContainer);\n"
        + "  var endPath = getXPathForNode(range.endContainer);\n"
        + "  var paths = startPath + '~' + range.startOffset + '~' + endPath + '~' + range.endOffset;\n"
        + "  var startClass = getClass(range.startContainer);\n"
        + "  var endClass = getClass(range.endContainer);\n"
        + "  var classes = startClass + '~' + endClass;\n"
        + "  return paths + '|' + classes;\n"
        + "}\n"
        + "function getXPathForNode(node) {\n"
        + "  var xpath = '';\n"
        + "  while(node && node.nodeName !== 'BODY') {\n"
        + "    var pos = 0;\n"
        + "    var temp = node;\n"
        + "    while(temp) {\n"
        + "      if (temp.nodeName === node.nodeName) {\n"
        + "        pos += 1;\n"
        + "      }\n"
        + "      temp = temp.previousSibling;\n"
        + "    }\n"
        + "    var name = (node.nodeType === 3) ? 'text()' : node.nodeName.toLowerCase();\n"
        + "    xpath = '/' + name + '[' + pos + ']' + xpath;\n"
        + "    node = node.parentNode;\n"
        + "  }\n"
        + "  return xpath;\n"
        + "}\n"
        + "function getClass(node) {\n"
        + "  var clas = '';\n"
        + "  while(node && node.nodeName !== 'BODY') {\n"
        + "    if (node.nodeType === 1) {\n"
        + "      clas += '/' + node.nodeName + '.' + node.getAttribute('class');\n"
        + "    }\n"
        + "  node = node.parentNode;\n"
        + "  }\n"
        + "  return clas;\n"
        + "}\n"
    
    static let decodeRange = "function decodeRange(encoded) {\n"
        + "  var parts = encoded.split('~');\n"
        + "  if (parts.length !== 4) {\n"
        + "    return null;\n"
        + "  }\n"
        + "  var startPath = document.evaluate('/html/body' + parts[0], document, null, XPathResult.ANY_UNORDERED_NODE_TYPE, null);\n"
        + "  var startText = startPath.singleNodeValue;\n"
        + "  var endPath = document.evaluate('/html/body' + parts[2], document, null, XPathResult.ANY_UNORDERED_NODE_TYPE, null);\n"
        + "  var endText = endPath.singleNodeValue;\n"
        + "  var startOffset = parseInt(parts[1]);\n"
        + "  var endOffset = parseInt(parts[3]);\n"
        + "  var range = new Range();\n"
        + "  range.setStart(startText, startOffset);\n"
        + "  range.setEnd(endText, endOffset);\n"
        + "  return range;\n"
        + "}\n"
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
