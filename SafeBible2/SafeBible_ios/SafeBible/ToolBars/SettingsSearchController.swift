//
//  SettingsSearchController.swift
//  Settings
//
//  Created by Gary Griswold on 9/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import UIKit

class SettingsSearchController: NSObject, UISearchResultsUpdating {
    
    private weak var controller: AppTableViewController?
    private let availableSection: Int
    private let searchController: UISearchController
    private var dataModel: SettingsModel?
    
    init(controller: AppTableViewController, selectionViewSection: Int) {
        self.controller = controller
        self.availableSection = selectionViewSection + 1
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.placeholder = NSLocalizedString("Find Languages",
                                                                        comment: "Languages search bar")
        super.init()
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.controller?.navigationItem.hidesSearchBarWhenScrolling = false
        //self.searchController.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    deinit {
        print("**** deinit SettingsSearchController ******")
    }
    
    func viewAppears(dataModel: SettingsModel?) {
        if let data = dataModel {
            self.dataModel = data
            self.controller?.navigationItem.searchController = self.searchController
        } else {
            self.dataModel = nil
            self.controller?.navigationItem.searchController = nil
        }
    }
    
    func isSearching() -> Bool {
        let searchBarEmpty: Bool = self.searchController.searchBar.text?.isEmpty ?? true
        return self.searchController.isActive && !searchBarEmpty
    }
    
    func updateSearchResults() {
        if isSearching() {
            updateSearchResults(for: self.searchController)
        }
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        print("****** INSIDE update Search Results ********")
        if let text = self.searchController.searchBar.text {
            if text.count > 0 {
                self.dataModel?.filterForSearch(searchText: text)
            }
            let sections = IndexSet(integer: self.availableSection)
            self.controller?.tableView.reloadSections(sections, with: UITableView.RowAnimation.automatic)
        }
    }
}
