//
//  AppSettingsViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 2/25/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class AppSettingsViewController : AppTableViewController, UITableViewDataSource {

    var dataModel: SettingsModel!
    
    let selectedSection: Int
    let availableSection: Int
    // The searchController can be instatiated in a subclass, but does not need to be
    var searchController: SettingsSearchController?
    
    init(selectedSection: Int) {
        self.selectedSection = selectedSection
        self.availableSection = selectedSection + 1
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("AppSettingsViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit AppSettingsViewController ******")
    }
    
    //
    // DataSource
    //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Must override numberOfRowsInSection.")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Must override cellForRowAt.")
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
                let initial = BibleInitialSelect()
                let bibles = initial.getBiblesSelected(locales: [language])
                SettingsDB.shared.addBibles(bibles: bibles)
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
    
    //
    // Delegate
    //
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let heading = titleForHeaderInSection(section: section) {
            let font = AppFont.sansSerif(style: .subheadline)
            let label = UILabel()
            //let rect = CGRect(x: 0, y: font.lineHeight, width: tableView.frame.size.width - 10, height: font.lineHeight)
            //let label = UILabel(frame: rect)
            label.font = font
            label.textAlignment = .center
            label.textColor = UIColor.darkGray
            label.text = heading
            return label
        } else {
            return nil
        }
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let font = AppFont.sansSerif(style: .subheadline)
        return 3 * font.lineHeight
    }
    
    /** This only draws a lightGray line at the bottom of any section. */
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.4)
        let label = UILabel(frame: rect)
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.4
    }
    
    // Identifies Add and Delete Rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCell.EditingStyle {
        if editingStyleForRowAt.section == self.selectedSection {
            return UITableViewCell.EditingStyle.delete
        }
        else if editingStyleForRowAt.section >= self.availableSection {
            return UITableViewCell.EditingStyle.insert
        }
        else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if indexPath.section == self.selectedSection {
            return NSLocalizedString("Remove", comment: "Red Delete Button text")
        } else {
            return nil
        }
    }
    
    // Keeps non-editable rows from indenting
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt: IndexPath) -> Bool {
        return true
    }
    
    // Limit the movement of rows
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let curSection = sourceIndexPath.section
        let newSection = proposedDestinationIndexPath.section
        if newSection == curSection {
            return proposedDestinationIndexPath
        } else if newSection < curSection {
            return IndexPath(item: 0, section: curSection)
        } else {
            // It would be better if I could make this the last row in a section, but I don't know what this is.
            return sourceIndexPath
        }
    }
}
