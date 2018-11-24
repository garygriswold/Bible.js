//
//  TextSelectionMenu.swift
//  Settings
//
//  Created by Gary Griswold on 11/15/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import WebKit

enum SelectionUse {
    case highlight
    case bookmark
    case note
    case compare
    case share
}

extension WKWebView {
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        //print("canPerformAction \(action) \(sender)")
        switch action {
        case #selector(highlightHandler):
            return true
        case #selector(bookmarkHandler):
            return true
        case #selector(noteHandler):
            return true
        case #selector(compareHandler):
            return true
        case #selector(shareHandler):
            return true
        default:
            return false
        }
    }
    
    func createEditMenu() {
        
        var menuItems = [UIMenuItem]()
        
        let highlightTitle = NSLocalizedString("Highlight", comment: "Menu option Highlight Text")
        let highlight = UIMenuItem(title: highlightTitle, action: #selector(highlightHandler))
        menuItems.append(highlight)
        
        let bookmarkTitle = NSLocalizedString("Bookmark", comment: "Menu option to Bookmark verse")
        let bookmark = UIMenuItem(title: bookmarkTitle, action: #selector(bookmarkHandler))
        menuItems.append(bookmark)
        
        let noteTitle = NSLocalizedString("Note", comment: "Menu option to write note")
        let note = UIMenuItem(title: noteTitle, action: #selector(noteHandler))
        menuItems.append(note)
        
        let compareTitle = NSLocalizedString("Compare", comment: "Menu option to see verse in multiple versions")
        let compare = UIMenuItem(title: compareTitle, action: #selector(compareHandler))
        menuItems.append(compare)
        
        let shareTitle = NSLocalizedString("Share", comment: "Menu option to share verse with others")
        let share = UIMenuItem(title: shareTitle, action: #selector(shareHandler))
        menuItems.append(share)
        
        UIMenuController.shared.menuItems = menuItems
    }
    
    @objc func highlightHandler(sender: UIMenuItem) {
        self.findSelection(selectionUse: .highlight)
    }
    
    @objc func bookmarkHandler(sender: UIMenuController) {
        self.selectionVerseStart()
    }
    
    @objc func noteHandler(sender: UIMenuItem) {
        print("note clicked")
    }
    
    @objc func compareHandler(sender: UIMenuItem) {
        print("compare clicked")
    }
    
    @objc func shareHandler(sender: UIMenuItem) {
        print("share clicked")
    }
    
    private func selectionVerseStart() {
        let query = "var clas = '';\n"
            + "var select = window.getSelection();\n"
            + "if (select != null) {\n"
            + "  var range = select.getRangeAt(0);\n"
            + "  var startNode = range.startContainer;\n"
            + "  if (startNode.nodeType != 1) {\n"
            + "    startNode = startNode.parentElement;\n"
            + "  }\n"
            + "  clas = startNode.className;\n"
            + "}\n"
            + "clas;\n"
        print(query)
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: selectionVerseStart \(err)")
            }
            if let resp = data as? String {
                print("jsCallback has a response \(resp)")
                let resp2 = resp.replacingOccurrences(of: "-", with: "_")
                let parts = resp2.split(separator: "_")
                let verse = String(parts.last!)
                print(verse)
                self.insertBookmark(verse: verse)
                let ref = HistoryModel.shared.current()
                let bookmark = Note(bookId: ref.bookId, chapter: ref.chapter, verse: Int(verse) ?? 0)
                SettingsDB.shared.storeNote(note: bookmark)
            } else {
                print("ERROR: selectionVerseStart returns non-string \(String(describing: data))")
            }
        })
    }
    
    private func findSelection(selectionUse: SelectionUse) {
        let query = "var select = window.getSelection();\n"
            + "var range = select.getRangeAt(0);\n"
            + "var startNode = range.startContainer.parentElement;\n"
            + "var endNode = range.endContainer.parentElement;\n"
            + "var topNode = range.commonAncestorContainer;\n"
            + "if (topNode.nodeType === 3) {\n"
            + "  topNode = topNode.parentElement;\n"
            + "}\n"
            + "var elementList = [];\n"
            + "var isInSelection = false;\n"
            + "depthFirst(topNode);\n"
            + "var identList = [range.startOffset, range.endOffset];\n"
            + "for (var i=0; i<elementList.length; i++) {\n"
            + "  identList.push(findNode(elementList[i]));\n"
            + "}\n"
            + "window.getSelection().removeAllRanges();\n"
            + "identList.join('/');\n" // return to evaluateJavascript
            + "function depthFirst(node) {\n"
            + "  if (node === startNode) {\n"
            + "    isInSelection = true;\n"
            + "  }\n"
            + "  if (isInSelection && node.children.length == 0) {\n"
            + "    elementList.push(node);\n"
            + "  }\n"
            + "  if (node === endNode) {\n"
            + "    isInSelection = false;\n"
            + "  }\n"
            + "  for (var i=0; i<node.children.length; i++) {\n"
            + "    depthFirst(node.children[i]);\n"
            + "  }\n"
            + "}\n"
            + "function findNode(node) {\n"
            + "  var clas = node.className;\n"
            + "  var list = document.getElementsByClassName(clas);\n"
            + "  for (var i=0; i<list.length; i++) {\n"
            + "    var item = list[i];\n"
            + "    if (item == node) {\n"
            + "      return(clas + ':' + i);\n"
            + "    }\n"
            + "  }\n"
            + "  return null;\n"
            + "}\n"
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let resp = data as? String {
                print(resp)
                let selection = Selection(selection: resp)
                switch selectionUse {
                case .highlight:
                    let colorPicker = ColorPicker(webView: self)
                    self.addSubview(colorPicker)
                case .bookmark:
                    _ = 2
                case .note:
                    _ = 3
                case .compare:
                    _ = 4
                case .share:
                    _ = 5
                }
                print(selection)
            }
            if let err = error {
                print("ERROR: findSelection \(err)")
            }
        })
    }
    
    @objc public func touchHandler(sender: UITapGestureRecognizer) {
        let it = sender.view?.backgroundColor
        sender.view?.superview?.removeFromSuperview()
        print("tapped colored dot \(it)")
        // have selection respond to user selection by inserting selection.
        // Use History to get reference
    }
    
    private func insertBookmark(verse: String) {
        let commands = "var node = document.getElementsByClassName('verse\(verse)')[0];\n"
            // Keep the following in case I am able to load images
            //+ "node = node.nextSibling;\n"
            //+ "var item = document.createElement('img');\n"
            //+ "item.setAttribute('src', 'images/gen-bookmark.png');\n"
            //+ "item.setAttribute('class', 'bookmark');\n"
            + "var item = document.createElement('span');\n"
            + "item.innerHTML = '&#x1F516; '\n"   /// NotePad &#x1F5D2;
            + "var result = node.parentElement.insertBefore(item, node);\n"
        self.evaluateJavaScript(commands, completionHandler: { data, error in
            if let err = error {
                print("ERROR: insertBookmark \(err)")
            }
        })
    }
    
    func addNotes(reference: Reference) {
        let notes: [Note] = SettingsDB.shared.getNotes(bookId: reference.bookId, chapter: reference.chapter,
                                                       bibleId: reference.bibleId)
        for note in notes {
            if note.bookmark {
                self.insertBookmark(verse: String(note.verse))
            }
        }
        
    }
}

