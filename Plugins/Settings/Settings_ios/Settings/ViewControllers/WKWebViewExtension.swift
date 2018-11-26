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
            + "var range = select.getRangeAt(0);\n"
            + "installEffect(range, 'book');\n"
            + "window.getSelection().removeAllRanges();\n"
            + "encodeRange(range);\n"
            + Note.installEffect
            + Note.encodeRange
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: insertBookmarkIcon \(err)")
            }
            if let range = data {
                print("RANGE found \(range)")
            }
        })
    }
    
    @objc func noteHandler(sender: UIMenuItem) {
        let query = "var select = window.getSelection();\n"
            + "var range = select.getRangeAt(0);\n"
            + "installEffect(range, 'note');\n"
            + "window.getSelection().removeAllRanges();\n"
            + "encodeRange(range);\n"
            + Note.installEffect
            + Note.encodeRange
        self.evaluateJavaScript(query, completionHandler: { data, error in
            if let err = error {
                print("ERROR: insertNoteIcon \(err)")
            }
            if let range = data {
                print("RANGE found \(range)")
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
 
    @objc public func colorTouchHandler(sender: UITapGestureRecognizer) {
        sender.view?.superview?.removeFromSuperview()
        if let color = sender.view?.backgroundColor {
            let hexColor = ColorPicker.toHEX(color: color)
            print("tapped colored dot \(hexColor)")
            let query = "var select = window.getSelection();\n"
                + "var range = select.getRangeAt(0);\n"
                + "installEffect(range, 'lite', '\(hexColor)');\n"
                + "window.getSelection().removeAllRanges();\n"
                + "encodeRange(range);\n"
                + Note.installEffect
                + Note.encodeRange
            self.evaluateJavaScript(query, completionHandler: { data, error in
                if let err = error {
                    print("ERROR: insertHighlight \(err)")
                }
                if let range = data {
                    print("RANGE found \(range)")
                }
            })
        }
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

