//
//  VersionViewDataSource.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class VersionViewDataSource : NSObject, UITableViewDataSource, UISearchResultsUpdating {
    
    var searchCell: VersionSearchCell?
    let dataModel = VersionModel()
    
    var tableView: UITableView? // needed by updateSearchResults
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override init() {
        super.init()
        
        // search, section 1, row 0
        self.searchCell = VersionSearchCell(searchBar: self.searchController.searchBar)
        // Setup the Search Controller
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        //navigationItem.searchController = searchController // suggested by Ray
        
    }
    
    // Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView // needed by updateSearchResults
        return 3
    }
    
    // Customize the section headings for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "My Bibles"
        case 1: return "Other Bibles"
        default: return nil
        }
    }
    
    // Customize the section footer for each section
    // fun tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {}
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.dataModel.selectedCount
        case 1: return 1
        case 2:
            if isSearching() {
                return self.dataModel.filteredCount
            } else {
                return self.dataModel.availableCount
            }
        default: fatalError("Unknown number of sections")
        }
    }
    
    // Return the row cell for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return self.dataModel.selectedCell(tableView: tableView, indexPath: indexPath)
        case 1:
            switch indexPath.row {
            case 0: return self.searchCell!
            default: fatalError("Unknown row \(indexPath.row) in section 4")
            }
        case 2:
            return self.dataModel.availableCell(tableView: tableView, indexPath: indexPath, inSearch: isSearching())
        default: fatalError("Unknown section \(indexPath.section)")
        }
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 0 || indexPath.section == 2)
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let destination = IndexPath(item: 0, section: 2)
            self.dataModel.moveSelectedToAvailable(source: indexPath.row,
                                                   destination: destination.row, inSearch: isSearching())
            tableView.moveRow(at: indexPath, to: destination)
            if isSearching() {
                updateSearchResults(for: searchController)
            }
        } else if editingStyle == UITableViewCellEditingStyle.insert {
            let length = self.dataModel.selectedCount
            let destination = IndexPath(item: length, section: 0)
            self.dataModel.moveAvailableToSelected(source: indexPath.row,
                                                   destination: destination.row, inSearch: isSearching())
            tableView.moveRow(at: indexPath, to: destination)
        }
    }
    
    // Return true for each row that can be moved
    func tableView(_ tableView: UITableView, canMoveRowAt: IndexPath) -> Bool {
        return (canMoveRowAt.section == 0)
    }
    
    // Commit the row move in the data source
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        self.dataModel.moveSelected(source: sourceIndexPath.row, destination: destinationIndexPath.row)
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        print("****** INSIDE update Search Results ********")
        print("found \(searchController.searchBar.text)")
        if let text = self.searchController.searchBar.text {
            if text.count > 0 {
                self.dataModel.filterForSearch(searchText: text)
            }
            let sections = IndexSet(integer: 2)
            self.tableView?.reloadSections(sections, with: UITableViewRowAnimation.automatic)
        }
    }
    
    func isSearching() -> Bool {
        print("****** INSIDE isSearching ******")
        let searchBarEmpty = self.searchController.searchBar.text?.isEmpty ?? true
        return self.searchController.isActive && !searchBarEmpty
    }
}
