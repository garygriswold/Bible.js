//
//  SearchViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/15/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//
import Foundation
import UIKit

class ConcordanceViewController: AppTableViewController, UITableViewDataSource {
    
    static let VIEW_SEARCHES = 0
    static let VIEW_LAST_SEARCH = 1
    static var VIEW_GROUP_SIZE = 3
   
    static func push(controller: UIViewController?, section: Int?) {
        let searchController = ConcordanceViewController(section: section)
        controller?.navigationController?.pushViewController(searchController, animated: true)
    }
 
    var section: Int? // Only set for second page for single book of Bible
    private var searchController: ConcordanceSearchController!
    var typeControl: UISegmentedControl!

    init(section: Int?) {
        self.section = section
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
        
        if self.section == nil {
            self.navigationItem.title = NSLocalizedString("Word Search", comment: "Title of Search page")
        } else {
            let bible = HistoryModel.shared.currBible
            let bookId = ConcordanceModel.shared.resultsByBook[self.section!][0].bookId
            self.navigationItem.title = bible.tableContents?.getBook(bookId: bookId)?.name
        }
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "concordanceSearch")
        self.tableView.register(ConcordanceResultCell.self, forCellReuseIdentifier: "concordanceResult")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        self.tableView.dataSource = self
        
        self.createToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = false
        
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
        self.searchController.updateSearchBar()
        if ConcordanceModel.shared.resultsByBook.count == 0 {
            self.searchController.performLastSearch()
        } else {
            self.typeControl.selectedSegmentIndex = ConcordanceViewController.VIEW_LAST_SEARCH
            self.tableView.reloadData()
        }
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardInfo: Dictionary = note.userInfo {
            if let keyboardRect: CGRect = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = keyboardRect.minY
                let bounds = self.view.bounds
                self.tableView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: keyboardTop)
            }
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.tableView.frame = self.view.bounds
    }
    
    private func createToolbar() {
        if let nav = self.navigationController {
            
            nav.toolbar.isTranslucent = false
            nav.toolbar.barTintColor = AppFont.backgroundColor
        }
        let history = NSLocalizedString("Searches", comment: "Concordance search history")
        let results = NSLocalizedString("Last Search", comment: "Result of last concordance search")
        self.typeControl = UISegmentedControl(items: [history, results])
        self.typeControl.selectedSegmentIndex = ConcordanceViewController.VIEW_LAST_SEARCH
        self.typeControl.addTarget(self, action: #selector(viewTypeHandler), for: .valueChanged)
        
        let typeCtrl = UIBarButtonItem(customView: typeControl)
        self.setToolbarItems([typeCtrl], animated: true)
    }
    
    @objc func viewTypeHandler(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if index == ConcordanceViewController.VIEW_LAST_SEARCH {
            self.searchController.updateSearchBar()
        } else {
            ConcordanceModel.shared.clearSearch()
            self.searchController.clearSearchBar()
        }
        self.typeControl.selectedSegmentIndex = index
        self.tableView.reloadData()
    }
    
    //
    // DataSource
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            let bookCount = ConcordanceModel.shared.resultsByBook.count
            if self.section == nil {
                return bookCount
            } else {
                return (bookCount < 1) ? bookCount : 1
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let concordance = ConcordanceModel.shared
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            if self.section == nil {
                let count = concordance.resultsByBook[section].count
                let max = ConcordanceViewController.VIEW_GROUP_SIZE + 1
                return (count < max) ? count : max
            } else {
                return concordance.resultsByBook[self.section!].count
            }
        } else {
            print("table view history count \(concordance.historyCount)")
            return concordance.historyCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            let cell = tableView.dequeueReusableCell(withIdentifier: "concordanceResult", for: indexPath) as! ConcordanceResultCell
            cell.showLastResult(indexPath: indexPath, section: self.section)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "concordanceSearch", for: indexPath)
            cell.contentView.backgroundColor = AppFont.backgroundColor
            cell.textLabel?.textColor = AppFont.textColor
            cell.textLabel?.text = ConcordanceModel.shared.getHistory(row: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            if self.section == nil {
                //let bookId = ConcordanceModel.shared.resultsByBook[section][0].bookId
                //let bible = HistoryModel.shared.currBible
                //if let name = bible.tableContents?.getBook(bookId: bookId)?.name {
                //    return name
                //} else {
                return "  "
                //}
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_SEARCHES {
            ConcordanceModel.shared.removeHistory(row: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            let cell = tableView.cellForRow(at: indexPath) as! ConcordanceResultCell
            if cell.verse.text != nil {
                let wordRef = ConcordanceModel.shared.resultsByBook[indexPath.section][indexPath.row]
                HistoryModel.shared.changeReference(bookId: wordRef.bookId, chapter: Int(wordRef.chapter))
                NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                                object: HistoryModel.shared.current())
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                ConcordanceViewController.push(controller: self, section: indexPath.section)
            }
        } else {
            let search = ConcordanceModel.shared.getHistory(row: indexPath.row)
            self.searchController.setSearchBar(search: search)
            self.searchController.performLastSearch()
        }
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            return .none
        } else {
            return .delete
        }
    }
}
