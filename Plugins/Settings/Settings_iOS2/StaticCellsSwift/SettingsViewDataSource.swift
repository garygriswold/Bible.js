//
//  SettingsViewDataSource.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewDataSource : NSObject, UITableViewDataSource, UISearchResultsUpdating {
    
    let reviewCell = UITableViewCell()
    let feedbackCell = UITableViewCell()
    let textSliderCell = UITableViewCell()
    let textDisplayCell = UITableViewCell()
    let languagesCell = UITableViewCell()
    var searchCell: VersionSearchCell?
    let settingsModel = SettingsModel()
    
    var tableView: UITableView? // needed by updateSearchResults
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override init() {
        super.init()
        
        // reviewCell, section 0, row 0
        self.reviewCell.textLabel?.text = "Write A Review"
        self.reviewCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // feedbackCell, section 0, row 1
        self.feedbackCell.textLabel?.text = "Send Us Feedback"
        self.feedbackCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // textSlider, section 1, row 0
        self.textSliderCell.textLabel?.text = "Text Slider TBD"
        self.textSliderCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // textDisplay, section 1, row 1
        self.textDisplayCell.textLabel?.text = "For God so loved TBD"
        self.textDisplayCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // languages, section 2, row 0
        self.languagesCell.textLabel?.text = "Languages"
        self.languagesCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // search, section 4, row 0
        self.searchCell = VersionSearchCell(searchBar: self.searchController.searchBar)
        // Setup the Search Controller
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        //navigationItem.searchController = searchController // suggested by Ray

    }
    
    // Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView // needed by updateSearchResults
        return 6
    }
    
    // Customize the section headings for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 3: return "My Bibles"
        case 4: return "Other Bibles"
        default: return nil
        }
    }
    
    // Customize the section footer for each section
    // fun tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {}
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        case 2: return 1
        case 3: return self.settingsModel.getSelectedVersionCount()
        case 4: return 1
        case 5:
            if isFiltering() {
                return self.settingsModel.versFiltered.count
            } else {
                return self.settingsModel.getAvailableVersionCount()
            }
        default: fatalError("Unknown number of sections")
        }
    }
    
    // Return the row cell for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return self.reviewCell
            case 1: return self.feedbackCell
            default: fatalError("Unknown row \(indexPath.row) in section 0")
            }
        case 1:
            switch indexPath.row {
            case 0: return self.textSliderCell
            case 1: return self.textDisplayCell
            default: fatalError("Unknown row \(indexPath.row) in section 1")
            }
        case 2:
            switch indexPath.row {
            case 0: return self.languagesCell
            default: fatalError("Unknown row \(indexPath.row) in section 2")
            }
        case 3:
            let selectedCell = tableView.dequeueReusableCell(withIdentifier: "versionCell", for: indexPath)
            let version = self.settingsModel.getSelectedVersion(index: indexPath.row)
            selectedCell.textLabel?.text = "\(version.versionCode), \(version.versionName)"
            selectedCell.detailTextLabel?.text = "\(version.organizationName)"
            selectedCell.accessoryType = UITableViewCellAccessoryType.detailButton // not working
            return selectedCell
        case 4:
            switch indexPath.row {
            case 0: return self.searchCell!
            default: fatalError("Unknown row \(indexPath.row) in section 4")
            }
        case 5:
            let availableCell = tableView.dequeueReusableCell(withIdentifier: "versionCell", for: indexPath)
            var version: Version
            if isFiltering() {
                version = self.settingsModel.versFiltered[indexPath.row]
            } else {
                version = self.settingsModel.getAvailableVersion(index: indexPath.row)
            }
            availableCell.textLabel?.text = "\(version.versionCode), \(version.versionName)"
            availableCell.detailTextLabel?.text = "\(version.organizationName)"
            availableCell.accessoryType = UITableViewCellAccessoryType.detailButton // not working
            return availableCell
        default: fatalError("Unknown section \(indexPath.section)")
        }
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 3 || indexPath.section == 5)
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let destination = IndexPath(item: 0, section: 5)
            self.settingsModel.moveSelectedToAvailable(source: indexPath.row, destination: destination.row)
            tableView.moveRow(at: indexPath, to: destination)
        } else if editingStyle == UITableViewCellEditingStyle.insert {
            let length = self.settingsModel.getSelectedVersionCount()
            let destination = IndexPath(item: length, section: 3)
            self.settingsModel.moveAvailableToSelected(source: indexPath.row, destination: destination.row)
            tableView.moveRow(at: indexPath, to: destination)
        }
    }

    // Return true for each row that can be moved
    func tableView(_ tableView: UITableView, canMoveRowAt: IndexPath) -> Bool {
        return (canMoveRowAt.section == 3)
    }
    
    // Commit the row move in the data source
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        self.settingsModel.moveSelected(source: sourceIndexPath.row,
                                        destination: destinationIndexPath.row)
    }

    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        print("****** INSIDE update Search Results ********")
        print("found \(searchController.searchBar.text)")
        if let text = self.searchController.searchBar.text {
            if text.count > 0 {
                self.settingsModel.filterVersionsForSearchText(searchText: text)
                print("Filtered \(self.settingsModel.versFiltered)")
            }
            let sections = IndexSet(integer: 5)
            self.tableView?.reloadSections(sections, with: UITableViewRowAnimation.automatic)
        }
    }
    
    func isFiltering() -> Bool {
        print("****** INSIDE isFiltering ******")
        let searchBarEmpty = self.searchController.searchBar.text?.isEmpty ?? true
        return self.searchController.isActive && !searchBarEmpty
    }
}
