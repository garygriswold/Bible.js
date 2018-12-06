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
        let query = "var select = window.getSelection();\n"
            + "var range = select.getRangeAt(0);\n"
            + "var result = encodeRange(range);\n"
            + "select.removeAllRanges();\n"
            + "result;\n"
            + Note.encodeRange
        // This might be able to use the handle selection method.
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: compareHandler \(err)")
            }
            if let range = data {
                print("RANGE found \(range)")
            }
        })
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
        let notes: [Note] = SettingsDB.shared.getNotes(bookId: reference.bookId, chapter: reference.chapter)
        var varLine1: String
        for note in notes {
            if note.highlight != nil {
                varLine1 = "installEffect(range, 'lite', '\(note.highlight!)');\n"
            }
            else if note.bookmark {
                varLine1 = "installEffect(range, 'book');\n"
            }
            else if note.note != nil {
                varLine1 = "installEffect(range, 'note');\n"
            } else {
                varLine1 = ""
            }
            let query = "var range = decodeRange('\(note.selection)');\n"
                + varLine1
                + Note.decodeRange
                + Note.installEffect
            //print(query)
            //self.evaluateJavaScript(query, completionHandler: { data, error in
            //    if let err = error {
            //        print("ERROR: addNote \(err)")
            //    }
            //    if let range = data {
            //        print("RANGE found \(range)")
            //    }
            //})
        }
    }
    
    private func handleSelection(selectionUse: SelectionUse, color: String?) {
        var varLine1: String
        switch selectionUse {
        case .highlight:
            varLine1 = "installEffect(range, 'lite', '\(color!)');\n"
        case .bookmark:
            varLine1 = "installEffect(range, 'book');\n"
        case .note:
            varLine1 = "installEffect(range, 'note');\n"
        case .compare:
            varLine1 = ""
        }
        let query = "var select = window.getSelection();\n"
            + "var range = select.getRangeAt(0);\n"
            + varLine1
            + "var result = encodeRange(range);\n"
            + "select.removeAllRanges();\n"
            + "result;\n"
            + Note.installEffect
            + Note.encodeRange
        print(query)
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: handleSelection \(err)")
            }
            if let range = data as? String {
                print("RANGE found \(range)")
                let bookmark = (selectionUse == .bookmark)
                let highlight = (selectionUse == .highlight) ? color! : nil
                let text = (selectionUse == .note) ? "Note here?" : nil
                let ref = HistoryModel.shared.current()
                let note = Note(bookId: ref.bookId, chapter: ref.chapter, bibleId: ref.bibleId, selection: range,
                                bookmark: bookmark, highlight: highlight, note: text)
                SettingsDB.shared.storeNote(note: note)
            }
        })
    }
}

