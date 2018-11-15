//
//  TableContentsViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/21/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class TOCBooksViewController : AppViewController, UITableViewDataSource, UITableViewDelegate {

    private var dataModel: TableContentsModel!
    private var tableView: UITableView!
    private var topAnchor: NSLayoutConstraint!
    
    deinit {
        print("**** deinit TOCBooksViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Books", comment: "Table Contents view page title")
        let history = NSLocalizedString("History", comment: "Button to display History")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: history, style: .plain,
                                                                 target: self,
                                                                 action: #selector(historyHandler))
        // create Table view
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.tableView = UITableView(frame: frame, style: UITableView.Style.plain)
        self.tableView.backgroundColor = AppFont.groupTableViewBackground
        self.tableView.layer.borderWidth = 0.4
        self.tableView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        self.view.addSubview(self.tableView)

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.topAnchor = self.tableView.topAnchor.constraint(equalTo: margins.topAnchor)
        self.topAnchor.isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        self.createToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataModel = HistoryModel.shared.currTableContents
        self.dataModel.clearFilteredBooks()
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        self.navigationController?.isToolbarHidden = true
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.dataModel.clearFilteredBooks()
        self.tableView.reloadData()
        self.positionMidView()
    }
    
    @objc func historyHandler(sender: UIBarButtonItem) {
        let historyController = HistoryViewController()
        self.navigationController?.pushViewController(historyController, animated: true)
    }
    
    private func createToolbar() {
        if let nav = self.navigationController {
            
            nav.toolbar.isTranslucent = false
            nav.toolbar.barTintColor = AppFont.backgroundColor
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
        self.dataModel.clearFilteredBooks()
        let index = sender.selectedSegmentIndex
        if index == 0 {
            self.dataModel.sortBooksTraditional()
        } else {
            self.dataModel.sortBooksAlphabetical()
        }
        self.tableView.reloadData()
        self.positionMidView()
    }
    
    private func positionMidView() {
        var blankSpace: CGFloat = 0.0
        let contentHeight = self.tableView.contentSize.height
        let safeHeight = self.view.safeAreaLayoutGuide.layoutFrame.height
        if contentHeight < safeHeight {
            blankSpace = (safeHeight - contentHeight) / 2.0
        }
        if blankSpace != self.topAnchor.constant {
            self.topAnchor.isActive = false
            self.topAnchor = self.tableView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: blankSpace)
            self.topAnchor.isActive = true
        }
    }

    //
    // Data Source
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModel.bookCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.dataModel.generateBookCell(tableView: tableView, indexPath: indexPath)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.dataModel.sideIndex
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String,
                   at index: Int) -> Int {
        self.dataModel.filterBooks(letter: title)
        tableView.reloadData()
        self.positionMidView()
        return -1
    }
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let book = self.dataModel.getBook(row: indexPath.row) {
            tableView.deselectRow(at: indexPath, animated: true)
            let chaptersController = TOCChaptersViewController(book: book)
            self.navigationController?.pushViewController(chaptersController, animated: true)
        }
    }
}
