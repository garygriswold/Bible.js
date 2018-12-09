//
//  CompareViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/8/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class CompareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let note: Note
    private var tableView: UITableView!
    private let dataModel: BibleModel
    
    init(note: Note) {
        self.note = note
        self.dataModel = BibleModel(availableSection: 0, language: nil, selectedOnly: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.note = Note(bookId: "JHN", chapter: 3, bibleId: "ENGESV", selection: "", classes: "", bookmark: false, highlight: nil, note: nil)
        self.dataModel = BibleModel(availableSection: 0, language: nil, selectedOnly: true)
        super.init(coder: coder)
    }
    
    deinit {
        print("**** deinit CompareViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = ""// self.note.reference How will I get book name.
        
        self.tableView = UITableView(frame: self.view.frame, style: UITableView.Style.plain)
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
    }
    
    @objc func addBibleHandler(sender: UIBarButtonItem) {
        print("clicked add bible handler")
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
        let bible = dataModel.getSelectedBible(row: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: "compareVerseCell", for: indexPath) as! CompareVerseCell
        let text = "You are the salt of the earth. But if the salt loses its saltiness,"
           + " how can it be made salty again? It is no longer good for anything,"
           + " except to be thrown out and trampled underfoot. You are the light of the world."
           + " A town built on a hill cannot be hidden. Neither do people light a lamp and put it under a bowl."
           + "  Instead they put it on its stand, and it gives light to everyone in the house."
        cell.title.text = bible?.name
        cell.verse.text = text
        return cell
        
        // must read chapter and parse verse
    }
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}

class CompareVerseCell : UITableViewCell {
    
    let title = UILabel()
    let verse = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.title.font = AppFont.sansSerif(style: .headline)
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
