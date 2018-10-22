//
//  TableContentsViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/21/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class TOCBooksViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    var dataModel: TableContentsModel!
    var tableView: UITableView!
    
    deinit {
        print("**** deinit TableContentsViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
        self.view.backgroundColor = UIColor.white
        self.view = self.tableView // OR self.view.addSubview(self.tableView)

        self.navigationItem.title = NSLocalizedString("Books", comment: "Menu view page title")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        AppFont.updateSearchFontSize()
        
        self.tableView.dataSource = self
        //self.tableView.delegate = self.delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createToolbar()
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
    
    private func createToolbar() {
        if let nav = self.navigationController {
            
            nav.toolbar.isTranslucent = false
            nav.toolbar.barTintColor = .white
        }
        var items = [UIBarButtonItem]()
        
        let trad = NSLocalizedString("Traditional", comment: "Bible books in traditional sequence")
        let alpha = NSLocalizedString("Alphabetical", comment: "Bible books in alphabetical sequence")
        let sortControl = UISegmentedControl(items: [trad, alpha])
        sortControl.selectedSegmentIndex = 0
        sortControl.addTarget(self, action: #selector(sortHandler), for: .valueChanged)
        
        let sortCtrl = UIBarButtonItem(customView: sortControl)
        items.append(sortCtrl)
        
        self.setToolbarItems(items, animated: true)
    }
    
    @objc func sortHandler(sender: UISegmentedControl) {
        print("sort handler clicked")
        dataModel.clearFilteredBooks()
        let index = sender.selectedSegmentIndex
        if index == 0 {
            dataModel.sortBooksTraditional()
        } else {
            dataModel.sortBooksAlphabetical()
        }
        self.tableView.reloadData()
    }

    //
    // Data Source
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModel.bookCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.dataModel.generateCell(tableView: tableView, indexPath: indexPath)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.dataModel.sideIndex
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String,
                   at index: Int) -> Int {
        self.dataModel.filterBooks(letter: title)
        tableView.reloadData()
        return -1
    }
}
