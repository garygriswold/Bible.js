//
//  NotesListViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import WebKit

class NotesListViewController : AppViewController, UITableViewDataSource, UITableViewDelegate {
    
    static func push(controller: UIViewController?) {
        let notesListViewController = NotesListViewController()
        controller?.navigationController?.pushViewController(notesListViewController, animated: true)
    }
    
    private var tableView: UITableView!
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
        
        let notebook = NSLocalizedString("Notebook", comment: "Notes list view page title")
        self.navigationItem.title = (self.reference.book?.name ?? "") + " " + notebook
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
        //                                                         action: #selector(editHandler))

        // create Table view
        self.tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        self.tableView.backgroundColor = AppFont.groupTableViewBackground
        self.view.addSubview(self.tableView)
        
        self.tableView.register(NoteCell.self, forCellReuseIdentifier: "notesCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isToolbarHidden = true
    }
    
    //@objc func editHandler(sender: UIBarButtonItem) {
    //    self.tableView.setEditing(true, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
    //                                                             action: #selector(doneHandler))
    //}
    
    //@objc func doneHandler(sender: UIBarButtonItem) {
    //    self.tableView.setEditing(false, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
    //                                                             action: #selector(editHandler))
    //}
    
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
        cell!.passage.font = AppFont.sansSerif(style: .subheadline)
        cell!.passage.textColor = AppFont.textColor
        cell!.passage.text = noteRef.description(startVerse: note.startVerse, endVerse: note.endVerse)
        cell!.noteText.numberOfLines = 10
        cell!.noteText.font = AppFont.sansSerif(style: .footnote)
        cell!.noteText.textColor = AppFont.textColor
        if note.highlight != nil {
            cell!.iconGlyph.text = Note.liteIcon//"\u{1F58C}"//    "\u{1F3F7}"
            cell!.noteText.text = "Highlited text here"
        }
        else if note.bookmark {
            cell!.iconGlyph.text = Note.bookIcon//"\u{1F516}"
        }
        else if note.note != nil {
            cell!.iconGlyph.text = Note.noteIcon//"\u{1F5D2}"
            cell!.noteText.text = note.note
        }
        cell!.selectionStyle = .default
        cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
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
        }
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = self.notes[indexPath.row]
        if note.note != nil {
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
