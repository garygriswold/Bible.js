//
//  TOCChaptersViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/22/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class TOCChaptersViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var book: Book!
    var dataModel: TableContentsModel!
    var tableView: UITableView!
    
    deinit {
        print("**** deinit TOCChaptersViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
        self.view.backgroundColor = UIColor.white
        self.view = self.tableView // OR self.view.addSubview(self.tableView)
        
        self.navigationItem.title = NSLocalizedString("Chapters", comment: "Table Contents view page title")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        AppFont.updateSearchFontSize()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.createToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let curr = HistoryModel.shared.currBible()
        
        self.dataModel = TableContentsModel(bible: curr)
        self.dataModel.load()
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(preferredContentSizeChanged(note:)),
                           name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let notify = NotificationCenter.default
        notify.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        self.navigationController?.isToolbarHidden = true
    }
    
    /**
     * iOS 10 includes: .adjustsFontForContentSizeCategory, which can be set to each label to
     * perform automatic text size adjustment
     */
    @objc func preferredContentSizeChanged(note: NSNotification) {
        AppFont.userFontDelta = 1.0
        tableView.reloadData() // updates preferred font size in table
        AppFont.updateSearchFontSize()
    }
    
    //
    // Data Source
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.book.lastChapter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return self.dataModel.generateCell(tableView: tableView, indexPath: indexPath)
        return self.dataModel.generateChapterCell(tableView: tableView, indexPath: indexPath)
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HistoryModel.shared.changeReference(book: self.book, chapter: (indexPath.row + 1))
        self.navigationController?.popToRootViewController(animated: true)
    }
}
