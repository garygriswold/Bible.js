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
    
    private var tableView: UITableView!
    private var reference: Reference!
    private var notes: [Note]!
    
    deinit {
        print("**** deinit NotesListViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.reference = HistoryModel.shared.current()
        self.notes = NotesDB.shared.getNotes(bookId: reference.bookId)
        
        let notebook = NSLocalizedString("Notebook", comment: "Notes list view page title")
        self.navigationItem.title = (self.reference.book?.name ?? "") + " " + notebook
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))

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
    
    @objc func editHandler(sender: UIBarButtonItem) {
        print("edit handler clicked")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                 action: #selector(doneHandler))
    }
    
    @objc func doneHandler(sender: UIBarButtonItem) {
        print("done handler clicked")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
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
            cell!.iconGlyph.text = "\u{1F3F7}"
            cell!.noteText.text = "Highlited text here"
        }
        else if note.bookmark {
            cell!.iconGlyph.text = "\u{1F516}"
        }
        else if note.note != nil {
            cell!.iconGlyph.text = "\u{1F5D2}"
            cell!.noteText.text = note.note
        }
        cell!.selectionStyle = .default
        cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell!
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = self.notes[indexPath.row]
        if note.note != nil {
            let noteEditViewController = NoteEditViewController(note: note, webView: nil)
            self.navigationController?.pushViewController(noteEditViewController, animated: true)
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
}
