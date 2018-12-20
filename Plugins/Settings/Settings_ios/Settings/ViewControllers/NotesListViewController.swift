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
        
        let title = self.reference.book?.name ?? ""
            + " " + NSLocalizedString("Notebook", comment: "Notes list view page title")
        self.navigationItem.title = title
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath)
        cell.backgroundColor = AppFont.backgroundColor
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = noteRef.description(startVerse: note.startVerse, endVerse: note.endVerse)
        if note.highlight != nil {
            cell.detailTextLabel?.text = "Highlite"
        }
        else if note.bookmark {
            cell.detailTextLabel?.text = "Bookmark"
        }
        else if note.note != nil {
            cell.detailTextLabel?.text = note.note
        } else {
            cell.detailTextLabel?.text = ""
        }
        cell.selectionStyle = .default
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
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
            
        }
    }
}


