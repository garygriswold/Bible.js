//
//  CompareViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/8/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class CompareViewController: AppViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let note: Note
    private var tableView: UITableView!
    private let dataModel: BibleModel
    
    init(note: Note) {
        self.note = note
        self.dataModel = BibleModel(availableSection: 0, language: nil, selectedOnly: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("CompareViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit CompareViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        let bibleId = HistoryModel.shared.current().bibleId
        let reference = Reference(bibleId: bibleId, bookId: note.bookId, chapter: note.chapter)
        let verses = (note.startVerse != note.endVerse) ? "\(note.startVerse)-\(note.endVerse)" : String(note.startVerse)
        self.navigationItem.title = reference.description() + ":" + verses
        
        self.tableView = UITableView(frame: self.view.frame, style: UITableView.Style.plain)
        self.tableView.backgroundColor = AppFont.backgroundColor
        self.view.addSubview(self.tableView)
        
        self.tableView.register(CompareVerseCell.self, forCellReuseIdentifier: "compareVerseCell")

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBibleHandler))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        
        let navController = self.navigationController!.topViewController
        navController!.navigationItem.rightBarButtonItem = saveButton;
        navController!.navigationItem.leftBarButtonItem = doneButton;
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = self.view.safeAreaLayoutGuide
        self.tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margin.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margin.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margin.bottomAnchor).isActive = true
    }
    
    @objc func addBibleHandler(sender: UIBarButtonItem) {
        print("NOT YET IMPLEMENTED, because need to support multiple versions first.")
        let bibleController = SettingsViewController(settingsViewType: .bible)
        self.navigationController?.pushViewController(bibleController, animated: true)
    }
    
    @objc func doneHandler(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    //
    // DataSource
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.selectedCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bible = dataModel.getSelectedBible(row: indexPath.row) // should I if let?
        let cell = tableView.dequeueReusableCell(withIdentifier: "compareVerseCell", for: indexPath) as! CompareVerseCell
        cell.contentView.backgroundColor = AppFont.backgroundColor
        cell.title.text = bible?.name
        cell.title.textColor = AppFont.textColor
        cell.verse.textColor = AppFont.textColor
        let reference = Reference(bibleId: bible!.bibleId, bookId: note.bookId, chapter: note.chapter) // bible! might fail
        let pageModel = BiblePageModel()
        pageModel.loadCell(reference: reference, startVerse: note.startVerse, endVerse: note.endVerse,
                           cell: cell, table: tableView, indexPath: indexPath)
        return cell
    }
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("NOT YET IMPLEMENTED, because need to support multiple versions first.")
    }
}

class CompareVerseCell : UITableViewCell {
    
    let title = UILabel()
    let verse = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.title.font = AppFont.sansSerif(style: .caption1)
        self.contentView.addSubview(self.title)
        
        self.verse.numberOfLines = 0
        self.verse.font = AppFont.serif(style: .body)
        self.contentView.addSubview(self.verse)
        
        let inset = self.contentView.frame.width * 0.05
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        
        self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: inset).isActive = true
        self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: inset).isActive = true
        
        self.verse.translatesAutoresizingMaskIntoConstraints = false
        
        self.verse.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: inset / 2.0).isActive = true
        self.verse.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: inset).isActive = true
        self.verse.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -inset).isActive = true
        self.verse.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -inset).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("CompareVerseCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit CompareVerseCell ******")
    }
}
