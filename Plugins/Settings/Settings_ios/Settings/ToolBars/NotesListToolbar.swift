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
    private var selectControl: UISegmentedControl!
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
       
        let note = "  \(Note.noteIcon)   "
        let lite = "  \(Note.liteIcon)   "
        let book = "  \(Note.bookIcon)   "
        self.selectControl = UISegmentedControl(items: [note, lite, book])
        self.selectControl.isMomentary = true
        self.selectControl.addTarget(self, action: #selector(selectHandler), for: .valueChanged)
        let select = UIBarButtonItem(customView: self.selectControl)
        items.append(select)
        items.append(spacer)
        
        self.files = UIBarButtonItem(barButtonSystemItem: .organize, target: self,
                                     action: #selector(filesHandler))
        items.append(self.files)
        items.append(spacer)
        
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
    
    @objc func selectHandler(sender: UIBarButtonItem) {
        switch self.selectControl.selectedSegmentIndex {
        case 0:
            self.includeNotes = !self.includeNotes
        case 1:
            self.includeLites = !self.includeLites
        case 2:
            self.includeBooks = !self.includeBooks
        default:
            print("should never see this")
        }
        self.controller?.refresh(note: self.includeNotes, lite: self.includeLites, book: self.includeBooks)
    }
    
    @objc func exportHandler(sender: UIBarButtonItem) {
        NotesExportActionSheet.present(book: self.book, controller: self.controller)
    }
    
    @objc func filesHandler(sender: UIBarButtonItem) {
        FileListViewController.push(controller: self.controller)
    }
}
