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
        
        let shareTitle = NSLocalizedString("Share", comment: "Menu option to share verse with others")
        let share = UIMenuItem(title: shareTitle, action: #selector(shareHandler))
        menuItems.append(share)
        
        let highlightTitle = NSLocalizedString("Highlight", comment: "Menu option Highlight Text")
        let highlight = UIMenuItem(title: highlightTitle, action: #selector(highlightHandler))
        menuItems.append(highlight)
        
        let noteTitle = NSLocalizedString("Note", comment: "Menu option to write note")
        let note = UIMenuItem(title: noteTitle, action: #selector(noteHandler))
        menuItems.append(note)
        
        let compareTitle = NSLocalizedString("Compare", comment: "Menu option to see verse in multiple versions")
        let compare = UIMenuItem(title: compareTitle, action: #selector(compareHandler))
        menuItems.append(compare)
        
        let bookmarkTitle = NSLocalizedString("Bookmark", comment: "Menu option to Bookmark verse")
        let bookmark = UIMenuItem(title: bookmarkTitle, action: #selector(bookmarkHandler))
        menuItems.append(bookmark)
        
        UIMenuController.shared.menuItems = menuItems
    }
    
    @objc func highlightHandler(sender: UIMenuItem) {
        let colorPicker = ColorPicker(webView: self)
        self.addSubview(colorPicker)
        // When user clicks on the color pallet, colorTouchHandler is called
    }
    
    @objc func bookmarkHandler(sender: UIMenuController) {
        let query = "var select = window.getSelection();\n"
            + "installEffect(select.getRangeAt(0), 'book');\n"
            + Note.installEffect
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: insertBookmarkIcon \(err)")
            }
        })
        //self.selectionVerseStart()
    }
    
    @objc func noteHandler(sender: UIMenuItem) {
        let query = "var select = window.getSelection();\n"
            + "installEffect(select.getRangeAt(0), 'note');\n"
            + Note.installEffect
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: insertNoteIcon \(err)")
            }
        })
    }
    
    @objc func compareHandler(sender: UIMenuItem) {
        print("compare clicked")
    }
    
    @objc func shareHandler(sender: UIMenuItem) {
        let query = "window.getSelection().toString();"
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: shareHandler \(err)")
            }
            if let text = data as? String {
                let attrs = [NSAttributedString.Key.font: AppFont.serif(style: .body),
                             NSAttributedString.Key.foregroundColor: UIColor.black]
                let string = NSAttributedString(string: text, attributes: attrs)
                let print = UISimpleTextPrintFormatter(attributedText: string)
        
                let share = UIActivityViewController(activityItems: [text, print],
                                                     applicationActivities: nil)
                share.popoverPresentationController?.sourceView = self//.view // so that iPads won't crash
                share.excludedActivityTypes = nil
                let rootController = UIApplication.shared.keyWindow?.rootViewController
                rootController!.present(share, animated: true, completion: nil)
            }
        })
    }
 /*
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
 */
 /*
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
                _ = Selection.factory(selection: resp)
                switch selectionUse {
                case .highlight:
                    let colorPicker = ColorPicker(webView: self)
                    self.addSubview(colorPicker)
                case .bookmark:
                    _ = 2
                case .note:
                    _ = 3
                    // This one primarily needs a starting point
                case .compare:
                    _ = 4
                    // This one can only be whole verses.  It can be multiple,
                    // but it cannot be part of a verse.
                }
            }
            if let err = error {
                print("ERROR: findSelection \(err)")
            }
        })
    }
 */
    @objc public func colorTouchHandler(sender: UITapGestureRecognizer) {
        sender.view?.superview?.removeFromSuperview()
        if let color = sender.view?.backgroundColor {
            let hexColor = ColorPicker.toHEX(color: color)
            print("tapped colored dot \(hexColor)")
            let query = "var select = window.getSelection();\n"
                + "installEffect(select.getRangeAt(0), 'lite', '\(hexColor)');\n"
                + Note.installEffect
            self.evaluateJavaScript(query, completionHandler: { data, error in
                if let err = error {
                    print("ERROR: insertHighlight \(err)")
                }
            })
        }
        // have selection respond to user selection by inserting selection.
        // Use History to get reference
    }

    func addNotes(reference: Reference) {
        let notes: [Note] = SettingsDB.shared.getNotes(bookId: reference.bookId, chapter: reference.chapter,
                                                       bibleId: reference.bibleId)
        for note in notes {
            if note.bookmark {
                //self.insertBookmark(verse: String(note.verse))
            }
        }
    }
}

