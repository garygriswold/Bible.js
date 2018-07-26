//
//  SettingsViewDataSource.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewDataSource : NSObject, UITableViewDataSource {
    
    let reviewCell = UITableViewCell()
    let feedbackCell = UITableViewCell()
    let textSliderCell = UITableViewCell()
    let textDisplayCell = UITableViewCell()
    let languagesCell = UITableViewCell()
    let searchCell = UITableViewCell()
    let settingsModel = SettingsModel()
    
    let cellBackground = UIColor.white
    
    override init() {
        super.init()
        
        // reviewCell, section 0, row 0
        self.reviewCell.backgroundColor = cellBackground
        self.reviewCell.textLabel?.text = "Write A Review"
        self.reviewCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // feedbackCell, section 0, row 1
        self.feedbackCell.backgroundColor = cellBackground
        self.feedbackCell.textLabel?.text = "Send Us Feedback"
        self.feedbackCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // textSlider, section 1, row 0
        self.textSliderCell.backgroundColor = cellBackground
        self.textSliderCell.textLabel?.text = "Text Slider TBD"
        self.textSliderCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // textDisplay, section 1, row 1
        self.textDisplayCell.backgroundColor = cellBackground
        self.textDisplayCell.textLabel?.text = "For God so loved TBD"
        self.textDisplayCell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // languages, section 2, row 0
        self.languagesCell.backgroundColor = cellBackground
        self.languagesCell.textLabel?.text = "Languages"
        self.languagesCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // search, section 4, row 0
        self.searchCell.backgroundColor = cellBackground
        self.searchCell.textLabel?.text = "Search"
        self.searchCell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    // Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
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
        case 4: return self.settingsModel.getAvailableVersionCount() + 1
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
            if let selected = selectedCell as? VersionCell {
                selected.versionCode = version.versionCode
            }
            selectedCell.textLabel?.text = "\(version.versionCode), \(version.versionName)"
            selectedCell.detailTextLabel?.text = "\(version.organizationName)"
            selectedCell.accessoryType = UITableViewCellAccessoryType.detailButton // not working
            return selectedCell
        case 4:
            if indexPath.row == 0 {
                return self.searchCell
            } else {
                let otherCell = tableView.dequeueReusableCell(withIdentifier: "versionCell", for: indexPath)
                let version = self.settingsModel.getAvailableVersion(index: indexPath.row - 1)
                otherCell.textLabel?.text = "\(version.versionCode), \(version.versionName)"
                otherCell.detailTextLabel?.text = "\(version.organizationName)"
                otherCell.accessoryType = UITableViewCellAccessoryType.detailButton // not working
                return otherCell
            }
        default: fatalError("Unknown section")
        }
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 3 || (indexPath.section == 4 && indexPath.row > 0))
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if let versionCode = self.getVersionCode(tableView: tableView, indexPath: indexPath,
                                                     method: "delete-row") {
                self.settingsModel.removeSelectedVersion(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                // Now, I need to figure out how to locate where the new field is to be added in the availVersions
                // How do I identify the correct position.
            }
        } else if editingStyle == UITableViewCellEditingStyle.insert {
            
        }
    }

    // Return true for each row that can be moved
    func tableView(_ tableView: UITableView, canMoveRowAt: IndexPath) -> Bool {
        return (canMoveRowAt.section == 3)
    }
    
    // Commit the row move in the data source
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let sourceIndex = sourceIndexPath.row
        let targetIndex = destinationIndexPath.row
        if let versionCode = self.getVersionCode(tableView: tableView, indexPath: sourceIndexPath,
                                                 method: "moveRowAt-source") {
            self.settingsModel.removeSelectedVersion(at: sourceIndex)
            self.settingsModel.insertSelectedVersion(versionCode: versionCode, at: targetIndex)
        }
        ///print("Updated: \(self.settingsModel.versSelected)")
    }
    
    private func getVersionCode(tableView: UITableView, indexPath: IndexPath, method: String) -> String? {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            print("SettingsViewDataSource.\(method) did not find cell at Index")
            return nil
        }
        guard let versionCell = cell as? VersionCell else {
            print("SettingsViewDataSource.\(method) cell was non-VersionCell")
            return nil
        }
        guard let versionCode = versionCell.versionCode else {
            print("SettingsViewDataSource.\(method) cell had no versionCode")
            return nil
        }
        return versionCode
    }
}
