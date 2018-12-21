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
    private weak var navigationController: UINavigationController?
    
    private var files: UIBarButtonItem!
    private var export: UIBarButtonItem!
    private var selectControl: UISegmentedControl!
    private var includeNotes: Bool = true
    private var includeLites: Bool = true
    private var includeBooks: Bool = true
    
    init(controller: NotesListViewController) {
        self.controller = controller
        self.navigationController = controller.navigationController
        
        if let nav = self.navigationController {
            
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
        if let nav = self.navigationController {
            nav.toolbar.barTintColor = AppFont.backgroundColor
        }
        let background = AppFont.nightMode ? UIColor(white: 0.20, alpha: 1.0) :
            UIColor(white: 0.95, alpha: 1.0)
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
        print("export button clicked")
        //let menuController = SettingsViewController(settingsViewType: .primary)
        //self.navigationController?.pushViewController(menuController, animated: true)
    }
    
    @objc func filesHandler(sender: UIBarButtonItem) {
        print("files icon clicked")
        //if let prior = HistoryModel.shared.back() {
        //    NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE, object: prior)
        //}
    }
}
