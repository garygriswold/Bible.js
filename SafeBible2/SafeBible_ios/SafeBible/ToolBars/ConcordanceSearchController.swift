//
//  ConcordanceSearchController.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/15/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class ConcordanceSearchController: NSObject, UISearchResultsUpdating, UISearchBarDelegate {
    
    private weak var controller: ConcordanceViewController?
    private let searchController: UISearchController
    
    init(controller: ConcordanceViewController) {
        self.controller = controller
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchBar.placeholder = NSLocalizedString("Search",
                                                                        comment: "Concordance search bar")
        super.init()
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.controller?.navigationItem.hidesSearchBarWhenScrolling = false
 
        self.searchController.searchBar.returnKeyType = .search
        
        self.searchController.searchBar.delegate = self
    }
    
    deinit {
        print("**** deinit ConcordanceSearchController ******")
    }

    func viewAppears() {
        self.controller?.navigationItem.searchController = self.searchController
    }
    
//    func isSearching() -> Bool {
//        let searchBarEmpty: Bool = self.searchController.searchBar.text?.isEmpty ?? true
//        return self.searchController.isActive && !searchBarEmpty
//    }
//
    func updateSearchBar() {
        self.searchController.searchBar.text = ConcordanceModel.shared.historyCurrent
    }
    
    func setSearchBar(search: String) {
        self.searchController.searchBar.text = search
    }
    
    func clearSearchBar() {
        self.searchController.searchBar.text = ""
    }

    //
    // UISearchResultsUpdating
    //
    func updateSearchResults(for searchController: UISearchController) {
        print("****** INSIDE update Search Results ********")
        if let text = self.searchController.searchBar.text {
            self.controller?.typeControl.selectedSegmentIndex = ConcordanceViewController.VIEW_SEARCHES
            if text.count > 0 {
                ConcordanceModel.shared.filterForSearch(searchText: text)
            } else {
                ConcordanceModel.shared.clearSearch()
            }
            self.controller?.tableView.reloadData()
        }
    }
    
    //
    // UISearchBarDelegate
    //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.performSearch(search: searchBar.text )
    }
    
    func performLastSearch() {
        self.performSearch(search: self.searchController.searchBar.text)
    }
    
    private func performSearch(search: String?) {
        if search != nil && search!.count > 0 {
            let bible = HistoryModel.shared.currBible
            let results = ConcordanceModel.shared.search(bible: bible, search: search!)
            print("search results count \(results.count)")
            self.controller?.typeControl.selectedSegmentIndex = ConcordanceViewController.VIEW_LAST_SEARCH
            self.controller?.tableView.reloadData()
        }
    }
}
