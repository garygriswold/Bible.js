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
        // I need to execute JS from here that will return the selection.
        // And it must also find the verse number.  i.e. look for a containing or preceeing record that
        // I already know the bible, book and chapter
        // Then I must add a bookmark by dom
        // Then I must store the bookmark in Notes.
        // Do I need to write insert/update methods,
        
        // when I present a chapter, I shoud retrieve notes for the chapter,
        //I think I should always retrieve the Notes record, and insert icons
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
    
    private func findSelectionAndVerse() {
        // start out with hello world
       // This method makes a call to get the selection
        // And it makes a call to
    }
    
    private func insertBookmark(verse: Int) {
        // insert a bookmark into the text
    }
}
