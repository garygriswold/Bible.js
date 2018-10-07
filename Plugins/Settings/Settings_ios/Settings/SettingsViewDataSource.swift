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
    private let dataModel: SettingsModel?
    private let settingsViewType: SettingsViewType
    private let selectedSection: Int
    private let availableSection: Int
    private let searchController: SettingsSearchController?
    private let textSizeSliderCell: TextSizeSliderCell
    
    init(controller: SettingsViewController, selectionViewSection: Int, searchController: SettingsSearchController?) {
        self.controller = controller
        self.dataModel = controller.dataModel
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
        switch self.settingsViewType {
        case .primary: return 4
        case .bible: return self.dataModel!.locales.count
        case .language: return 2
        }
    }
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.settingsViewType {
        case .primary:
            switch section {
            case 0: return 3
            case 1: return 1
            case 2: return 2
            case 3: return (UserMessageController.isAvailable()) ? 4 : 3
            default: fatalError("Unknown number of sections")
            }
        case .bible:
            switch section {
            case 0: return self.dataModel!.selectedCount
            default:
                let index = section - 1
                if let bibleModel = self.dataModel as? BibleModel {
                    return bibleModel.getAvailableBibleCount(section: index)
                } else {
                    return 0
                }
            }
        case .language:
            switch section {
            case 0: return self.dataModel!.selectedCount
            case 1:
                if self.searchController!.isSearching() {
                    return self.dataModel!.filteredCount
                } else {
                    return self.dataModel!.availableCount
                }
            default: fatalError("Unknown number of sections")
            }
        }
    }
    
    // Return the row cell for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.settingsViewType {
        case .primary:
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    let tocText = NSLocalizedString("Table of Contents", comment: "Table of Contents Title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: tocText)
                case 1:
                    let histText = NSLocalizedString("History", comment: "History Cell Title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: histText)
                case 2:
                    let videoText = NSLocalizedString("Videos", comment: "Videos Cell Title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: videoText)
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
                    let bibleText = NSLocalizedString("More Bibles", comment: "Clickable cell title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: bibleText)
                case 1:
                    let langText = NSLocalizedString("More Languages", comment: "Clickable cell title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: langText)
                default: fatalError("Unknown row \(indexPath.row) in section 2")
                }
            case 3:
                switch indexPath.row {
                case 0:
                    let reviewText = NSLocalizedString("Write A Review", comment: "Clickable cell title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: reviewText)
                case 1:
                    let commentText = NSLocalizedString("Send Us Comments", comment: "Clickable cell title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: commentText)
                case 2:
                    let privText = NSLocalizedString("Privacy Policy", comment: "Privacy Policy cell title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: privText)
                case 3:
                    let shareText = NSLocalizedString("Share SafeBible", comment: "Clickable cell title")
                    return self.genericCell(view: tableView, indexPath: indexPath, title: shareText)
                default: fatalError("Unknown row \(indexPath.row) in section 3")
                }
            default:
                fatalError("Unknown section \(indexPath.section) in .primary")
            }
        case .bible:
            switch indexPath.section {
            case 0:
                return self.dataModel!.selectedCell(tableView: tableView, indexPath: indexPath)
            default:
                return self.dataModel!.availableCell(tableView: tableView, indexPath: indexPath,
                                                     inSearch: false)
            }
        case .language:
            switch indexPath.section {
            case 0:
                return self.dataModel!.selectedCell(tableView: tableView, indexPath: indexPath)
            case 1:
                return self.dataModel!.availableCell(tableView: tableView, indexPath: indexPath, inSearch: self.searchController?.isSearching() ?? false)
            default: fatalError("Unknown section \(indexPath.section) in .language")
            }
        }
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch self.settingsViewType {
        case .primary: return false
        case .bible: return true
        case .language: return true
        }
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let destination = self.dataModel!.findAvailableInsertIndex(selectedIndex: indexPath)
            self.dataModel!.moveSelectedToAvailable(source: indexPath,
                                                   destination: destination,
                                                   inSearch: self.searchController?.isSearching() ?? false)
            tableView.moveRow(at: indexPath, to: destination)
            self.searchController?.updateSearchResults()
        } else if editingStyle == UITableViewCellEditingStyle.insert {
            let length = self.dataModel!.selectedCount
            let destination = IndexPath(item: length, section: self.selectedSection)
            self.dataModel!.moveAvailableToSelected(source: indexPath,
                                                   destination: destination,
                                                   inSearch: self.searchController?.isSearching() ?? false)
            tableView.moveRow(at: indexPath, to: destination)
            
            // When we move a language from available to selected, then select initial versions
            //if self.dataModel is LanguageModel {
            //    if let language = self.dataModel.getSelectedLanguage(row: destination.row) {
            //        let initial = BibleInitialSelect(adapter: self.dataModel.settingsAdapter)
            //        let bibles = initial.getBiblesSelected(locales: [language.locale])
            //        self.dataModel.settingsAdapter.addBibles(bibles: bibles)
            //    }
            //}
        }
    }

    // Return true for each row that can be moved
    func tableView(_ tableView: UITableView, canMoveRowAt: IndexPath) -> Bool {
        return (self.settingsViewType != .primary && canMoveRowAt.section == self.selectedSection)
    }
    
    // Commit the row move in the data source
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        self.dataModel!.moveSelected(source: sourceIndexPath.row, destination: destinationIndexPath.row)
    }
        
    private func genericCell(view: UITableView, indexPath: IndexPath, title: String) -> UITableViewCell {
        let cell = view.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
        cell.textLabel?.text = title
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
}
