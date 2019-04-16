//
//  SearchViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/15/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class ConcordanceViewController: AppTableViewController, UITableViewDataSource {
   
    static func push(controller: UIViewController?) {
        let searchController = ConcordanceViewController()
        controller?.navigationController?.pushViewController(searchController, animated: true)
    }
    
    private var searchController: ConcordanceSearchController!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.searchController = ConcordanceSearchController(controller: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ConcordanceViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit ConcordanceViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Word Search", comment: "Title of Search page")
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(ConcordanceInputCell.self, forCellReuseIdentifier: "concordanceInput")
        self.tableView.register(ConcordanceResultCell.self, forCellReuseIdentifier: "concordanceResult")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = false
        
        // When UserMessage is dismissed, it has sometimes left behind only the top half of the screen
        self.tableView.frame = self.view.bounds
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1.0))
        self.tableView.tableHeaderView = label
        
        self.tableView.dataSource = self
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.searchController.viewAppears()
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardInfo: Dictionary = note.userInfo {
            if let keyboardRect: CGRect = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = keyboardRect.minY
                let bounds = self.view.bounds
                self.tableView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: keyboardTop)
            }
        }
        // crashes when there are zero rows in table
        //self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.tableView.frame = self.view.bounds
    }
    
    //
    // DataSource
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let concordance = ConcordanceModel.shared
        print("table view count \(concordance.results.count)")
        return concordance.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let concordance = ConcordanceModel.shared
        let wordRef = concordance.results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "concordanceResult", for: indexPath) as! ConcordanceResultCell
        cell.contentView.backgroundColor = AppFont.backgroundColor

        cell.title.textColor = AppFont.textColor
        cell.title.text = "Genesis 1:1"

        cell.verse.textColor = AppFont.textColor
        let bible = HistoryModel.shared.currBible
        cell.verse.text = BibleDB.shared.selectVerse(bible: bible, wordRef: wordRef)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let concordance = ConcordanceModel.shared
        let verse = concordance.results[indexPath.row]
        print("clicked on verse \(verse)")
    }
}

class ConcordanceInputCell : UITableViewCell {
    
}

class ConcordanceResultCell : UITableViewCell {
    let title = UILabel()
    let verse = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.title.font = AppFont.sansSerif(style: .subheadline)
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
        fatalError("WordSearchResultCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit WordSearchResultCell ******")
    }
}
