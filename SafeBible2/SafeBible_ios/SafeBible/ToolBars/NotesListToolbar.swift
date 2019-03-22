//
//  NotesListToolbar.swift
//  Settings
//
//  Created by Gary Griswold on 12/21/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class NotesListToolbar {
    
    private weak var controller: NotesListViewController?
    
    private var book: Book
    private var files: UIBarButtonItem!
    private var export: UIBarButtonItem!
    private let noteLabel = UILabel()
    private let liteLabel = UILabel()
    private let bookLabel = UILabel()
    private var includeNotes: Bool = true
    private var includeLites: Bool = true
    private var includeBooks: Bool = true
    
    init(book: Book, controller: NotesListViewController) {
        self.book = book
        self.controller = controller
        
        //super.init()

        if let nav = self.controller?.navigationController {
            
            nav.toolbar.isTranslucent = false
            nav.toolbar.barTintColor = AppFont.backgroundColor
        }
        
        var items = [UIBarButtonItem]()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(spacer)
        
        items.append(self.itemSelector(label: self.noteLabel, icon: Note.noteIcon,
                                       action: #selector(notesBtnHandler)))
        items.append(self.itemSelector(label: self.liteLabel, icon: Note.liteIcon,
                                       action: #selector(liteBtnHandler)))
        items.append(self.itemSelector(label: self.bookLabel, icon: Note.bookIcon,
                                       action: #selector(bookBtnHandler)))
        items.append(spacer)
        
        if NotesDB.shared.countDB() > 1 {
            self.files = UIBarButtonItem(barButtonSystemItem: .organize, target: self,
                                         action: #selector(filesHandler))
            items.append(self.files)
            items.append(spacer)
        }
        
        let export = UIBarButtonItem(barButtonSystemItem: .action, target: self,
                                     action: #selector(exportHandler))
        items.append(export)
        items.append(spacer)
        
        self.controller!.setToolbarItems(items, animated: true)
    }
    
    func refresh() {
        if let nav = self.controller?.navigationController {
            nav.toolbar.barTintColor = AppFont.backgroundColor
        }
    }
    
    @objc func notesBtnHandler(sender: UIBarButtonItem) {
        self.includeNotes = !self.includeNotes
        self.noteLabel.backgroundColor = (self.includeNotes) ? AppFont.backgroundColor : UIColor.gray

        self.controller?.refresh(note: self.includeNotes, lite: self.includeLites, book: self.includeBooks)
    }
    
    @objc func liteBtnHandler(sender: UIBarButtonItem) {
        self.includeLites = !self.includeLites
        self.liteLabel.backgroundColor = (self.includeLites) ? AppFont.backgroundColor: UIColor.gray
        self.controller?.refresh(note: self.includeNotes, lite: self.includeLites, book: self.includeBooks)
    }
    
    @objc func bookBtnHandler(sender: UIBarButtonItem) {
        self.includeBooks = !self.includeBooks
        self.bookLabel.backgroundColor = (self.includeBooks) ? AppFont.backgroundColor: UIColor.gray
        self.controller?.refresh(note: self.includeNotes, lite: self.includeLites, book: self.includeBooks)
    }
    
    @objc func exportHandler(sender: UIBarButtonItem) {
        NotesExportActionSheet.present(book: self.book, controller: self.controller, button: sender)
    }
    
    @objc func filesHandler(sender: UIBarButtonItem) {
        FileListViewController.push(controller: self.controller)
    }
    
    private func itemSelector(label: UILabel, icon: String, action: Selector) -> UIBarButtonItem {
        label.text = " \(icon) "
        label.backgroundColor = AppFont.backgroundColor
        let gesture = UITapGestureRecognizer(target: self, action: action)
        gesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(gesture)
        label.isUserInteractionEnabled = true
        return UIBarButtonItem(customView: label)
    }
}
