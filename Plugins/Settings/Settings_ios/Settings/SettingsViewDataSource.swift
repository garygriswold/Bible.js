//
//  SettingsViewDataSource.swift
//  Settings
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

class SettingsViewDataSource : NSObject, UITableViewDataSource {
    
    private weak var controller: SettingsViewController?
    private let dataModel: SettingsModel
    private let settingsViewType: SettingsViewType
    private let selectedSection: Int
    private let availableSection: Int
    private let searchController: SettingsSearchController
    private let textSizeSliderCell: TextSizeSliderCell
    private let language: Language? // Used only in .bible settingsViewType
    
    init(controller: SettingsViewController, selectionViewSection: Int, searchController: SettingsSearchController) {
        self.controller = controller
        self.dataModel = controller.dataModel
        self.language = controller.language
        self.searchController = searchController
        self.settingsViewType = controller.settingsViewType
        self.selectedSection = selectionViewSection
        self.availableSection = selectionViewSection + 1
        
        // Text Size Cell
        self.textSizeSliderCell = TextSizeSliderCell(controller: self.controller!, style: .default, reuseIdentifier: nil)
       
        super.init()
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
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.settingsViewType == .primary && section < self.selectedSection {
            switch section {
            case 0: return (UserMessageController.isAvailable()) ? 3 : 2
            case 1: return 1
            case 2: return 1
            default: fatalError("Unknown number of sections")
            }
        } else {
            switch section {
            case self.selectedSection: return self.dataModel.selectedCount
            case self.availableSection:
                if self.searchController.isSearching() {
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
                    reviewCell.textLabel?.text = NSLocalizedString("Write A Review", comment: "Clickable cell title")
                    reviewCell.textLabel?.font = AppFont.sansSerif(style: .body)
                    reviewCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    return reviewCell
                case 1:
                    let feedbackCell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
                    feedbackCell.textLabel?.text = NSLocalizedString("Send Us Feedback", comment: "Clickable cell title")
                    feedbackCell.textLabel?.font = AppFont.sansSerif(style: .body)
                    feedbackCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    return feedbackCell
                case 2:
                    let messageCell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
                    messageCell.textLabel?.text = NSLocalizedString("Share SafeBible", comment: "Clickable cell title")
                    messageCell.textLabel?.font = AppFont.sansSerif(style: .body)
                    messageCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    return messageCell
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
                    languagesCell.textLabel?.text = NSLocalizedString("Languages", comment: "Clickable cell title")
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
                return self.dataModel.availableCell(tableView: tableView, indexPath: indexPath, inSearch: self.searchController.isSearching())
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
            let index = self.dataModel.findAvailableInsertIndex(selectedIndex: indexPath.row)
            let destination = IndexPath(item: index, section: self.availableSection)
            self.dataModel.moveSelectedToAvailable(source: indexPath.row,
                                                   destination: destination.row,
                                                   inSearch: self.searchController.isSearching())
            tableView.moveRow(at: indexPath, to: destination)
            self.searchController.updateSearchResults()
        } else if editingStyle == UITableViewCellEditingStyle.insert {
            let length = self.dataModel.selectedCount
            let destination = IndexPath(item: length, section: self.selectedSection)
            self.dataModel.moveAvailableToSelected(source: indexPath.row,
                                                   destination: destination.row,
                                                   inSearch: self.searchController.isSearching())
            tableView.moveRow(at: indexPath, to: destination)
            
            // When self.language is not null and we are moving an available Bible to selected
            // We also want to add the Language to selected Languages.
            if let lang = self.language {
                self.dataModel.settingsAdapter.addLanguage(language: lang)
            }
            // When I move a language from, available to selected, then select initial versions
            if self.dataModel is LanguageModel {
                if let language = self.dataModel.getSelectedLanguage(row: destination.row) {
                    let initial = BibleInitialSelect(adapter: self.dataModel.settingsAdapter)
                    let bibles = initial.getBiblesSelected(locales: [language.locale])
                    self.dataModel.settingsAdapter.addBibles(bibles: bibles)
                }
            }
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
}
