//
//  TextSelectionMenu.swift
//  Settings
//
//  Created by Gary Griswold on 11/15/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import WebKit

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
        //case #selector(_lookup):
        //    return true
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
        print("highlight clicked")
    }
    
    @objc func bookmarkHandler(sender: UIMenuController) {
        print("bookmark clicked")
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
        print(commands)
        self.evaluateJavaScript(commands, completionHandler: { data, error in
            if let err = error {
                print("ERROR: insertBookmark \(err)")
            }
        })
    }
}

