//
//  SettingsViewDataSource.swift
//  Settings
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewDataSource : NSObject, UITableViewDataSource, UISearchResultsUpdating {
    
    private weak var controller: SettingsViewController?
    private let dataModel: SettingsModelInterface
    private let settingsViewType: SettingsViewType
    private let selectedSection: Int
    private let availableSection: Int
    private let searchController: UISearchController
    private let textSizeSliderCell: TextSizeSliderCell
    private var language: Language? // Used only in .bible settingsViewType
    
    init(controller: SettingsViewController, selectionViewSection: Int) {
        self.controller = controller
        self.dataModel = controller.dataModel
        self.language = controller.language
        self.searchController = UISearchController(searchResultsController: nil)
        self.settingsViewType = controller.settingsViewType
        switch settingsViewType {
        case .primary:
            self.searchController.searchBar.placeholder = "Find Bibles"
        case .language:
            self.searchController.searchBar.placeholder = "Find Languages"
        case .bible:
            self.searchController.searchBar.placeholder = "Find Bibles"
        }
        self.selectedSection = selectionViewSection
        self.availableSection = selectionViewSection + 1
        
        // Text Size Cell
        self.textSizeSliderCell = TextSizeSliderCell(controller: self.controller!, style: .default, reuseIdentifier: nil)
       
        super.init()
        
        // Setup the Search Controller
        let numRequiredForSearchBar = 3
        if self.dataModel.availableCount > numRequiredForSearchBar {
            self.searchController.searchResultsUpdater = self
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.controller?.navigationItem.searchController = self.searchController
            self.controller?.navigationItem.hidesSearchBarWhenScrolling = false
            // These don't seem to have an effect when search controller is set to naviation item
            //self.searchController.searchBar.searchBarStyle = UISearchBarStyle.default // (defult or minimal or prominent)
            //self.searchController.searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    deinit {
        print("**** deinit SettingsViewDataSource \(self.settingsViewType) ******")
    }
    
    // Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.settingsViewType == .primary {
            return 5
        } else {
            return 2
        }
    }
    
    // Customize the section headings for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch self.settingsViewType {
        case .primary:
            if section == self.selectedSection { return "My Bibles" }
            else if section == self.availableSection { return "More Bibles" }
            else { return nil }
        case .language:
            if section == self.selectedSection { return "My Languages" }
            else if section == self.availableSection { return "More Languages" }
            else { return nil }
        case .bible:
            if section == self.selectedSection { return "My Bibles" }
            else if section == self.availableSection {
                if let lang = self.language?.localized {
                    return lang + " Bibles"
                } else {
                    return "More Bibles"
                }
            }
            else { return nil }
        }
    }
    
    // Customize the section footer for each section
    // fun tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {}
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.settingsViewType == .primary && section < self.selectedSection {
            switch section {
            case 0: return 2
            case 1: return 1
            case 2: return 1
            default: fatalError("Unknown number of sections")
            }
        } else {
            switch section {
            case self.selectedSection: return self.dataModel.selectedCount
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
        //print("found \(searchController.searchBar.text)")
        if let text = self.searchController.searchBar.text {
            if text.count > 0 {
                self.dataModel.filterForSearch(searchText: text)
            }
            let sections = IndexSet(integer: self.availableSection)
            self.controller?.tableView.reloadSections(sections, with: UITableViewRowAnimation.automatic)
        }
    }
    
    func isSearching() -> Bool {
        let searchBarEmpty: Bool = self.searchController.searchBar.text?.isEmpty ?? true
        return self.searchController.isActive && !searchBarEmpty
    }
}
