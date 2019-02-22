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
        // When user clicks on the color picker, colorTouchHandler is called
    }
    
    @objc func bookmarkHandler(sender: UIMenuController) {
        self.handleSelection(selectionUse: .bookmark, color: nil)
    }
    
    @objc func noteHandler(sender: UIMenuItem) {
        self.handleSelection(selectionUse: .note, color: nil)
    }
    
    @objc func compareHandler(sender: UIMenuItem) {
        self.handleSelection(selectionUse: .compare, color: nil)
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
 
    @objc public func colorTouchHandler(sender: UITapGestureRecognizer) {
        sender.view?.superview?.removeFromSuperview()
        if let color = sender.view?.backgroundColor {
            let hexColor = ColorPicker.toHEX(color: color)
            print("tapped colored dot \(hexColor)")
            self.handleSelection(selectionUse: .highlight, color: hexColor)
        }
    }

    func addNotes(reference: Reference) {
        let notes: [Note] = NotesDB.shared.getNotes(bookId: reference.bookId, chapter: reference.chapter)
        for note in notes {
            if note.highlight != nil {
                let query = "var range = decodeRange(\"\(note.selection)\");\n"
                + "installEffect(range, 'lite_saved', '\(note.noteId)', '\(note.highlight!)');\n"
                self.evaluateJavaScript(query, completionHandler: { data, error in
                    if let err = error {
                        print("ERROR: addNote Highlite \(err)")
                    }
                })
            }
            else if note.bookmark {
                self.installIcon(verse: note.startVerse, selectionUse: .bookmark, noteId: note.noteId)
            }
            else if note.note != nil {
                self.installIcon(verse: note.startVerse, selectionUse: .note, noteId: note.noteId)
            }
        }
    }
    
    private func handleSelection(selectionUse: SelectionUse, color: String?) {
        let noteId = Note.genNoteId()
        var varLine1 = ""
        if selectionUse == .highlight {
            varLine1 = "installEffect(range, 'lite_select', '\(noteId)', '\(color!)');\n"
        }
        let query = "var select = window.getSelection();\n"
            + "var range = select.getRangeAt(0);\n"
            + "var result = encodeRange(range);\n"
            + varLine1
            + "select.removeAllRanges();\n"
            + "result;\n"
        //print(query)
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: handleSelection \(err)")
            }
            if let result = data as? String {
                let parts = result.split(separator: "|")
                if parts.count != 3 {
                    print("ERROR: selection did not return 3 parts: \(result)")
                }
                let selection = String(parts[0])
                let classes = (parts.count > 0) ? String(parts[1]) : ""
                let bookmark = (selectionUse == .bookmark)
                let highlight = (selectionUse == .highlight) ? color! : nil
                let text = (selectionUse == .note && parts.count > 1) ? String(parts[2]) : nil
                let ref = HistoryModel.shared.current()
                let note = Note(noteId: noteId, bookId: ref.bookId, chapter: ref.chapter, bibleId: ref.bibleId,
                                selection: selection, classes: classes, bookmark: bookmark, highlight: highlight, note: text)
                if selectionUse == .compare {
                    CompareViewController.present(note: note)
                } else {
                    NotesDB.shared.storeNote(note: note)
                }
                if selectionUse == .note {
                    NoteEditViewController.present(note: note, webView: self)
                }
                if selectionUse == .bookmark || selectionUse == .note {
                    self.installIcon(verse: note.startVerse, selectionUse: selectionUse, noteId: noteId)
                }
            }
        })
    }
    
    private func installIcon(verse: Int, selectionUse: SelectionUse, noteId: String) {
        let currRef = HistoryModel.shared.current()
        var source: String
        var verseId: String
        var type: String = ""
        var icon: String = ""
        if currRef.isShortsands {
            source = "SS"
            verseId = currRef.nodeId(verse: verse)
        } else {
            source = "DBP"
            verseId = "verse\(verse)"
        }
        if selectionUse == .bookmark {
            type = "book"
            icon = "&#x1F516;"
        } else if selectionUse == .note {
            type = "note"
            icon = "&#x1F5D2;"
        }
        let command = "installIcon('\(source)', '\(verseId)', '\(type)', '\(icon)', '\(noteId)');"
        self.evaluateJavaScript(command, completionHandler: { data, error in
            if let err = error {
                print("ERROR: installIcon \(err)")
            }
        })
    }
}
