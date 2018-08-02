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
    
    let settingsViewType: SettingsViewType
    let selectedSection: Int
    let searchSection: Int
    let availableSection: Int
    
    let textSizeSliderCell: TextSizeSliderCell
    //let textSampleCell: TextSampleCell
    var searchCell: SearchCell?
    let dataModel: SettingsModelInterface
    
    var tableView: UITableView? // needed by updateSearchResults
    
    let searchController = UISearchController(searchResultsController: nil)
    
    init(settingsViewType: SettingsViewType, selectionViewSection: Int) {
        self.settingsViewType = settingsViewType
        switch settingsViewType {
        case .primary:
            self.dataModel = VersionModel()
            self.searchController.searchBar.placeholder = "Find Bibles"
        case .language:
            self.dataModel = LanguageModel()
            self.searchController.searchBar.placeholder = "Find Languages"
        case .version:
            self.dataModel = VersionModel()
            self.searchController.searchBar.placeholder = "Find Bibles"
        }
        self.selectedSection = selectionViewSection
        self.searchSection = selectionViewSection + 1
        self.availableSection = selectionViewSection + 2
        
        // Text Size Cell
        self.textSizeSliderCell = TextSizeSliderCell(style: .default, reuseIdentifier: nil)
        //self.textSampleCell = TextSampleCell(style: .default, reuseIdentifier: nil)
        
        super.init()
        
        // search Cell
        self.searchCell = SearchCell(searchBar: self.searchController.searchBar)
        // Setup the Search Controller
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        //navigationItem.searchController = searchController // suggested by Ray
    }
    
    // Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView = tableView // needed by updateSearchResults
        self.textSizeSliderCell.tableView = self.tableView
        if self.settingsViewType == .primary {
            return 6
        } else {
            return 3
        }
    }
    
    // Customize the section headings for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.settingsViewType == .language {
            switch section {
            case self.selectedSection: return "My Languages"
            case self.searchSection: return "Other Other"
            default: return nil
            }
        } else {
            switch section {
            case self.selectedSection: return "My Bibles"
            case self.searchSection: return "Other Bibles"
            default: return nil
            }
        }
    }
    
    // Customize the section footer for each section
    // fun tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {}
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.settingsViewType == .primary && section < self.selectedSection {
            switch section {
            case 0: return 2
            //case 1: return 2
            case 1: return 1
            case 2: return 1
            default: fatalError("Unknown number of sections")
            }
        } else {
            switch section {
            case self.selectedSection: return self.dataModel.selectedCount
            case self.searchSection: return 1
            case self.availableSection:
                if isSearching() {
                    return self.dataModel.filteredCount
                } else {
                    return self.dataModel.availableCount
                }
            default: fatalError("Unknown number of sections")
            }
        }
    }
    
    // Return the row cell for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.settingsViewType == .primary && indexPath.section < self.selectedSection {
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    let reviewCell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
                    reviewCell.textLabel?.text = "Write A Review"
                    reviewCell.textLabel?.font = AppFont.sansSerif(style: .body)
                    reviewCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    return reviewCell
                case 1:
                    let feedbackCell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
                    feedbackCell.textLabel?.text = "Send Us Feedback"
                    feedbackCell.textLabel?.font = AppFont.sansSerif(style: .body)
                    feedbackCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    return feedbackCell
                default: fatalError("Unknown row \(indexPath.row) in section 0")
                }
            case 1:
                switch indexPath.row {
                case 0:
                    return self.textSizeSliderCell
                //case 1:
                //    //return self.textSampleCell
                //    let textDisplayCell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
                //    textDisplayCell.textLabel?.text = "Your word is a lamp to my feet and a light to my path." +
                //    " Your word is a lamp to my feet and a light to my path."
                //    textDisplayCell.textLabel?.font = AppFont.sansSerif(style: .body)
                //    textDisplayCell.textLabel?.numberOfLines = 0
                //    textDisplayCell.textLabel?.lineBreakMode = .byWordWrapping
                //    textDisplayCell.selectionStyle = UITableViewCellSelectionStyle.none
                //    return textDisplayCell
                default: fatalError("Unknown row \(indexPath.row) in section 1")
                }
            case 2:
                switch indexPath.row {
                case 0:
                    let languagesCell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
                    languagesCell.textLabel?.text = "Languages"
                    languagesCell.textLabel?.font = AppFont.sansSerif(style: .body)
                    languagesCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    return languagesCell
                default: fatalError("Unknown row \(indexPath.row) in section 2")
                }
            default: fatalError("")
            }
        } else {
            switch indexPath.section {
            case self.selectedSection:
                return self.dataModel.selectedCell(tableView: tableView, indexPath: indexPath)
            case self.searchSection:
                switch indexPath.row {
                case 0: return self.searchCell!
                default: fatalError("Unknown row \(indexPath.row) in section 4")
                }
            case self.availableSection:
                return self.dataModel.availableCell(tableView: tableView, indexPath: indexPath, inSearch: isSearching())
            default: fatalError("Unknown section \(indexPath.section)")
            }
        }
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == self.selectedSection || indexPath.section == self.availableSection)
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let destination = IndexPath(item: 0, section: self.availableSection)
            self.dataModel.moveSelectedToAvailable(source: indexPath.row,
                                                   destination: destination.row, inSearch: isSearching())
            tableView.moveRow(at: indexPath, to: destination)
            if isSearching() {
                updateSearchResults(for: searchController)
            }
        } else if editingStyle == UITableViewCellEditingStyle.insert {
            let length = self.dataModel.selectedCount
            let destination = IndexPath(item: length, section: self.selectedSection)
            self.dataModel.moveAvailableToSelected(source: indexPath.row,
                                                   destination: destination.row, inSearch: isSearching())
            tableView.moveRow(at: indexPath, to: destination)
        }
    }

    // Return true for each row that can be moved
    func tableView(_ tableView: UITableView, canMoveRowAt: IndexPath) -> Bool {
        return (canMoveRowAt.section == self.selectedSection)
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
            let sections = IndexSet(integer: self.availableSection)
            self.tableView?.reloadSections(sections, with: UITableViewRowAnimation.automatic)
        }
    }
    
    func isSearching() -> Bool {
        print("****** INSIDE isSearching ******")
        let searchBarEmpty = self.searchController.searchBar.text?.isEmpty ?? true
        return self.searchController.isActive && !searchBarEmpty
    }
}
