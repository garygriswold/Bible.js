//
//  NotesListViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import WebKit

class NotesListViewController : AppTableViewController, UITableViewDataSource {
    
    static func push(controller: UIViewController?) {
        let notesListViewController = NotesListViewController()
        controller?.navigationController?.pushViewController(notesListViewController, animated: true)
    }
    
    private var reference: Reference!
    private var notes: [Note]!
    private var toolBar: NotesListToolbar!
    
    deinit {
        print("**** deinit NotesListViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.reference = HistoryModel.shared.current()
        
        self.toolBar = NotesListToolbar(book: reference.book!, controller: self)
        
        self.notes = NotesDB.shared.getNotes(bookId: reference.bookId, note: true, lite: true, book: true)
        
        let notes = NSLocalizedString("Notes", comment: "Notes list view page title")
        self.navigationItem.title = (self.reference.book?.name ?? "") + " " + notes
        
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 50.0; // set to whatever your "average" cell height i
        
        self.tableView.register(NoteCell.self, forCellReuseIdentifier: "notesCell")
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = false
    }
    
    // This method is called by NotesListToolbar
    func refresh(note: Bool, lite: Bool, book: Bool) {
        self.notes = NotesDB.shared.getNotes(bookId: reference.bookId, note: note, lite: lite, book: book)
        self.tableView.reloadData()
    }
    
    //
    // Data Source
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = self.notes[indexPath.row]
        let noteRef = note.getReference()
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as? NoteCell
        guard cell != nil else { fatalError("notesCell must be type NotesCell") }
        cell!.backgroundColor = AppFont.backgroundColor
        //cell!.passage.font = AppFont.sansSerif(style: .body)
        cell!.passage.font = AppFont.sansSerif(style: .subheadline)
        cell!.passage.textColor = AppFont.textColor
        cell!.passage.text = noteRef.description(startVerse: note.startVerse, endVerse: note.endVerse)
            + "  (\(noteRef.bibleName))"
        cell!.noteText.numberOfLines = 10
        //cell!.noteText.font = AppFont.sansSerif(style: .subheadline)
        cell!.noteText.font = AppFont.sansSerif(style: .body)
        cell!.noteText.textColor = AppFont.textColor
        if note.highlight != nil {
            cell!.iconGlyph.text = Note.liteIcon//"\u{1F58C}"//    "\u{1F3F7}"
            cell!.noteText.text = note.text
            cell!.accessoryType = .none
        }
        else if note.bookmark {
            cell!.iconGlyph.text = Note.bookIcon//"\u{1F516}"
            cell!.noteText.text = nil
            cell!.accessoryType = .none
        }
        else if note.note {
            cell!.iconGlyph.text = Note.noteIcon//"\u{1F5D2}"
            cell!.noteText.text = note.text
            cell!.accessoryType = .disclosureIndicator
        }
        cell!.selectionStyle = .default
        return cell!
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = self.notes[indexPath.row]
            self.notes.remove(at: indexPath.row)
            NotesDB.shared.deleteNote(noteId: note.noteId)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            // Remove Note from current pages if present.
            ReaderViewQueue.shared.reloadIfActive(reference: note.getReference())
        }
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = self.notes[indexPath.row]
        if note.note {
            NoteEditViewController.push(note: note, controller: self)
        } else {
            let ref = HistoryModel.shared.current()
            if note.bibleId != ref.bibleId || note.bookId != ref.bookId || note.chapter != ref.chapter {
                let noteRef = note.getReference()
                if let book = noteRef.book {
                    HistoryModel.shared.changeReference(book: book, chapter: noteRef.chapter)
                    NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                                    object: HistoryModel.shared.current())
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // Identifies Add and Delete Rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
}
