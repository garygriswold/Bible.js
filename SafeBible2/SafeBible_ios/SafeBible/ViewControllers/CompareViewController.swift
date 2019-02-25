//
//  CompareViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/8/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class CompareViewController: AppTableViewController, UITableViewDataSource {
    
    static func present(note: Note) {
        let compare = CompareViewController(note: note)
        compare.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        compare.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navController = UINavigationController(rootViewController: compare)
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController!.present(navController, animated: true, completion: nil)
    }
    
    private let note: Note
    private let dataModel: BibleModel
    
    init(note: Note) {
        self.note = note
        // get selected and available, available is needed for CompareActionSheet
        self.dataModel = BibleModel(availableSection: 0, language: nil, selectedOnly: false)
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
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBibleHandler))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        
        let navController = self.navigationController!.topViewController
        navController!.navigationItem.rightBarButtonItem = saveButton;
        navController!.navigationItem.leftBarButtonItem = doneButton;
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(CompareVerseCell.self, forCellReuseIdentifier: "compareVerseCell")
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(newBibleAndLangSelected(note:)),
                                               name: ReaderPagesController.NEW_COMPARE, object: nil)
        
    }
    
    @objc func addBibleHandler(sender: UIBarButtonItem) {
        CompareActionSheet.present(controller: self, bibleModel: self.dataModel)
    }
    
    @objc func doneHandler(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func newBibleAndLangSelected(note: NSNotification) {
        let bible = note.object as! Bible
        self.dataModel.selected.append(bible)
        self.tableView.reloadData()
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
        pageModel.loadCompareVerseCell(reference: reference, startVerse: note.startVerse,
                                       endVerse: note.endVerse, cell: cell, table: tableView,
                                       indexPath: indexPath)
        return cell
    }
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let bible = dataModel.getSelectedBible(row: indexPath.row) {
            HistoryModel.shared.changeBible(bible: bible)
            NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                            object: HistoryModel.shared.current())
            self.dismiss(animated: true, completion: nil)
        }
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
