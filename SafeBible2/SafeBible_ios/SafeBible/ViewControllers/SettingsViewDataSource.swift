//
//  SettingsViewDataSource.swift
//  Settings
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

class SettingsViewDataSource : NSObject, UITableViewDataSource {
    
    private weak var controller: BibleListViewController?
    private let dataModel: SettingsModel?
    private let settingsViewType: SettingsViewType
    private let selectedSection: Int
    private let availableSection: Int
    private let searchController: SettingsSearchController?
    
    init(controller: BibleListViewController, selectionViewSection: Int, searchController: SettingsSearchController?) {
        self.controller = controller
        self.dataModel = controller.dataModel
        self.searchController = searchController
        self.settingsViewType = controller.settingsViewType
        self.selectedSection = selectionViewSection
        self.availableSection = selectionViewSection + 1
       
        super.init()
    }
    
    deinit {
        print("**** deinit SettingsViewDataSource \(self.settingsViewType) ******")
    }
    
    // Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.settingsViewType {
        case .bible: return 1 + self.dataModel!.locales.count
        case .oneLang: return 2
        }
    }
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.settingsViewType {
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
        case .oneLang:
            switch section {
            case 0: return self.dataModel!.selectedCount
            case 1:
                if let bibleModel = self.dataModel as? BibleModel {
                    return bibleModel.getAvailableBibleCount(section: 0)
                } else {
                    return 0
                }
            default: fatalError("Unknown section \(section) in .oneLang")
            }
        }
    }
    
    // Return the row cell for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.settingsViewType {
        case .bible:
            switch indexPath.section {
            case 0:
                return self.dataModel!.selectedCell(tableView: tableView, indexPath: indexPath)
            default:
                return self.dataModel!.availableCell(tableView: tableView, indexPath: indexPath,
                                                     inSearch: false)
            }
        case .oneLang:
            switch indexPath.section {
            case 0:
                return self.dataModel!.selectedCell(tableView: tableView, indexPath: indexPath)
            case 1:
                return self.dataModel!.availableCell(tableView: tableView, indexPath: indexPath,
                                                     inSearch: false)
            default: fatalError("Unknown section \(indexPath.section) in .oneLang")
            }
        }
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch self.settingsViewType {
        case .bible: return true
        case .oneLang: return true
        }
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.deleteRow(tableView: tableView, indexPath: indexPath)
        } else if editingStyle == UITableViewCell.EditingStyle.insert {
            self.insertRow(tableView: tableView, indexPath: indexPath)
        }
    }
    
    func deleteRow(tableView: UITableView, indexPath: IndexPath) {
        let destination = self.dataModel!.findAvailableInsertIndex(selectedIndex: indexPath)
        self.dataModel!.moveSelectedToAvailable(source: indexPath,
                                                destination: destination,
                                                inSearch: self.searchController?.isSearching() ?? false)
        tableView.moveRow(at: indexPath, to: destination)
        self.searchController?.updateSearchResults()
    }
    
    func insertRow(tableView: UITableView, indexPath: IndexPath) {
        let length = self.dataModel!.selectedCount
        let destination = IndexPath(item: length, section: self.selectedSection)
        self.dataModel!.moveAvailableToSelected(source: indexPath,
                                                destination: destination,
                                                inSearch: self.searchController?.isSearching() ?? false)
        tableView.moveRow(at: indexPath, to: destination)
        
        // When we move a language from available to selected, then select initial versions
        if let model = self.dataModel as? LanguageModel {
            if let language = model.getSelectedLanguage(row: destination.row) {
                let initial = BibleInitialSelect(adapter: model.settingsAdapter)
                let bibles = initial.getBiblesSelected(locales: [language.locale])
                model.settingsAdapter.addBibles(bibles: bibles)
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
        self.dataModel!.moveSelected(source: sourceIndexPath.row, destination: destinationIndexPath.row)
    }
}
