//
//  NotesModel.swift
//  Settings
//
//  Created by Gary Griswold on 11/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import Foundation

struct Note {
    
    static let noteIcon = "\u{1F5D2}"
    static let bookIcon = "\u{1F516}"
    static let liteIcon = "\u{1F58C}"
    
    static func genNoteId() -> String {
        return UUID().uuidString
    }
    
    private static var regex0 = try! NSRegularExpression(pattern: "id=.+:.+:(\\d+)")
    private static var regex1 = try! NSRegularExpression(pattern: "cl=v .+_(\\d+)")
    private static var regex2 = try! NSRegularExpression(pattern: "cl=verse.*\\sv-(\\d+)")
    
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
    var note: Bool
    var highlight: String?      // color name in HEX, presence indicates highlight
    var text: String?

    // Used to instantiate after user does selection
    init(noteId: String, bookId: String, chapter: Int, bibleId: String, selection: String, classes: String,
         bookmark: Bool, note: Bool, highlight: String?, text: String?) {
        self.noteId = noteId
        self.bookId = bookId
        self.chapter = chapter
        self.datetime = Int(Date().timeIntervalSince1970)
        self.startVerse = 0
        self.endVerse = 0
        self.bibleId = bibleId
        self.selection = selection
        self.classes = classes
        self.bookmark = bookmark
        self.note = note
        self.highlight = highlight
        self.text = text
        
        let parts = classes.split(separator: "~")
        self.startVerse = getVerseNum(classes: String(parts[0]))
        if parts.count > 0 {
            self.endVerse = getVerseNum(classes: String(parts[1]))
        }
        print("verse: \(self.startVerse) to \(self.endVerse)")
    }
    
    // Used to instantiate from selection from Notes table
    init(noteId: String, bookId: String, chapter: Int, datetime: Int, startVerse: Int, endVerse: Int,
         bibleId: String, selection: String, classes: String, bookmark: Bool, note: Bool,
         highlight: String?, text: String?) {
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
        self.note = note
        self.highlight = highlight
        self.text = text
    }
    
    func getReference() -> Reference {
        return Reference(bibleId: self.bibleId, bookId: self.bookId, chapter: self.chapter)
    }
    
    private func getVerseNum(classes: String) -> Int {
        var result = self.getVerseNumHelper(classes: classes, regex: Note.regex0)
        if result == nil {
            result = self.getVerseNumHelper(classes: classes, regex: Note.regex1)
        }
        if result == nil {
            result = self.getVerseNumHelper(classes: classes, regex: Note.regex2)
        }
        if result == nil {
            result = 0
        }
        return result!
    }
    
    private func getVerseNumHelper(classes: String, regex: NSRegularExpression) -> Int? {
        var result = regex.matches(in: classes, range: NSMakeRange(0, classes.count))
        if result.count > 0 && result[0].numberOfRanges > 1 {
            return getSubstringInt(leaf: classes, result: result[0])
        } else {
            return nil
        }
    }
    
    private func getSubstringInt(leaf: String, result: NSTextCheckingResult) -> Int {
        let verse = result.range(at: 1)
        let start = leaf.index(leaf.startIndex, offsetBy: verse.location)
        let end = leaf.index(leaf.startIndex, offsetBy: verse.location + verse.length)
        let range = start..<end
        //print(leaf[range])
        return Int(leaf[range]) ?? 0
    }

    static let installEffect = "function installEffect(range, type, noteId, color) {\n"
        + "  if (type === 'lite_select') {\n"
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
        + "function installIcon(source, verseId, type, icon, noteId) {\n"
        + "  var ele = document.createElement('a');\n"
        + "  ele.setAttribute('id', noteId);\n"
        + "  ele.setAttribute('href', 'javascript:void(0);');\n"
        + "  var msg = 'window.webkit.messageHandlers.' + type + '.postMessage(\\'' + noteId + '\\');'\n"
        + "  ele.setAttribute('onclick', msg);\n"
        + "  ele.innerHTML = icon + ' ';\n"
        + "  var verseNode;\n"
        + "  if (source === 'SS') {\n"
        + "    verseNode = document.getElementById(verseId);\n"
        + "  } else { // source === 'DBP'\n"
        + "    verseNode = document.getElementsByClassName(verseId)[0];\n"
        + "  }\n"
        + "  verseNode.parentNode.insertBefore(ele, verseNode);\n"
        + "}\n"
    
    static let encodeRange = "function encodeRange(range) {\n"
        + "  var startPath = getXPathForNode(range.startContainer);\n"
        + "  var endPath = getXPathForNode(range.endContainer);\n"
        + "  var paths = startPath + '~' + range.startOffset + '~' + endPath + '~' + range.endOffset;\n"
        + "  var startClass = getClass(range.startContainer);\n"
        + "  var endClass = getClass(range.endContainer);\n"
        + "  var classes = startClass + '~' + endClass;\n"
        + "  return paths + '|' + classes + '|' + window.getSelection().toString();\n"
        + "}\n"
        // Note: window.getSelection().toString() excludes display: none nodes
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
        + "  while(node && node.nodeName !== 'BODY') {\n"
        + "    if (node.nodeType === 1 && node.nodeName !== 'A') {\n"
        + "      var id = node.getAttribute('id');\n"
        + "      if (id) {\n"
        + "        return 'id=' + id;\n"
        + "      } else {\n"
        + "        var clas = node.getAttribute('class');\n"
        + "        if (clas && (clas.startsWith('v ') || clas.startsWith('verse'))) {\n"
        + "          return 'cl=' + clas;\n"
        + "        }\n"
        + "      }\n"
        + "    }\n"
        + "    var prior = node.previousSibling;\n"
        + "    if (!prior) {\n"
        + "      prior = node.parentNode;\n"
        + "    }\n"
        + "    node = prior;\n"
        + "  }\n"
        + "  return null;\n"
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
    
    static let showHideSSFootnote = "function bibleShowNoteClick(nodeId) {\n"
        + "  var node = document.getElementById(nodeId);\n"
        + "  if (node) {\n"
        + "    node.setAttribute('onclick', \"bibleHideNoteClick('\" + nodeId + \"');\");\n"
        + "    var handChar = node.innerText.trim();\n"
        + "    if (handChar === '\\u261C' || handChar === '\\u261E') {\n"
        + "      node.setAttribute('style', 'color: #555555; background-color: #FFFFB4;');\n"
        + "    } else {\n"
        + "      node.setAttribute('style', 'color: #555555; background-color: #CEE7FF;');\n"
        + "    }\n"
        + "    for (var i=0; i<node.children.length; i++) {\n"
        + "      node.children[i].setAttribute('style', 'display:inline');\n"
        + "    }\n"
        + "  }\n"
        + "}\n"
        + "function bibleHideNoteClick(nodeId) {\n"
        + "  var node = document.getElementById(nodeId);\n"
        + "  if (node) {\n"
        + "    node.setAttribute('onclick', \"bibleShowNoteClick('\" + nodeId + \"');\");\n"
        + "    node.setAttribute('style', 'color: ##FFB4B5; background-color: #FFFFFF;');\n"
        + "    for (var i=0; i<node.children.length; i++) {\n"
        + "      node.children[i].setAttribute('style', 'display:none');\n"
        + "    }\n"
        + "  }\n"
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
