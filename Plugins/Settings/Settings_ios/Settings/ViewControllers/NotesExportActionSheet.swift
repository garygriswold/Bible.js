//
//  NotesExportActionSheet.swift
//  Settings
//
//  Created by Gary Griswold on 12/21/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class NotesExportActionSheet : UIAlertController {
    
    static func present(book: Book, controller: NotesListViewController?) {
        if controller != nil {
            let actions = NotesExportActionSheet(book: book, controller: controller!)
            controller!.present(actions, animated: true, completion: nil)
        } else {
            print("ERROR: could not present NotesExportActionSheet")
        }
    }
    
    private weak var controller: NotesListViewController?
    private let book: Book
    
    init(book: Book, controller: NotesListViewController) {
        self.book = book
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NotesExportActionSheet(coder:) is not implemented.")
    }
    
    override var preferredStyle: UIAlertController.Style { get { return .actionSheet } }
    
    override func loadView() {
        super.loadView()
        
        let notebook2Text = NSLocalizedString("Notebook to Text", comment: "Option on action sheet")
        let notes2TextTitle = "'\(self.book.name)' \(notebook2Text)"
        let notes2Text = UIAlertAction(title: notes2TextTitle, style: .default, handler: { _ in
            let notes = NotesDB.shared.getNotes(bookId: self.book.bookId, note: true, lite: true, book: true)
            NotesExportDocument.export(name: self.book.name, notes: notes)
        })
        self.addAction(notes2Text)
        
        let notebooks2Text = NSLocalizedString("All Notebooks to Text", comment: "Option on action sheet")
        let all2Text = UIAlertAction(title: notebooks2Text, style: .default, handler: { _ in
            let notes = NotesDB.shared.getNotes(bookId: nil, note: true, lite: true, book: true)
            NotesExportDocument.export(name: "AllMine", notes: notes)
        })
        self.addAction(all2Text)
        
        let notebook2Share = NSLocalizedString("Notebook to Share", comment: "Option on action sheet")
        let notes2ShareTitle = "'\(self.book.name)' \(notebook2Share)"
        let notes2Share = UIAlertAction(title: notes2ShareTitle, style: .default, handler: { _ in
            print("clicked on notes 2 share")
            //NotesExportDatabase.export(name: self.book.name)
        })
        self.addAction(notes2Share)
        
        let notebooks2Share = NSLocalizedString("All Notebooks to Share", comment: "Option on action sheet")
        let all2Share = UIAlertAction(title: notebooks2Share, style: .default, handler: { _ in
            NotesExportDatabase.export(name: self.book.name)
        })
        self.addAction(all2Share)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.addAction(cancel)
    }
}

