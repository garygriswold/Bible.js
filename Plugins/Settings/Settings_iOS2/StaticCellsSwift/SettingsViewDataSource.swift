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
        case 3: return self.settingsModel.getVersionCount()
        case 4: return self.settingsModel.getVersionCount() + 1
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
            let selectedCell = tableView.dequeueReusableCell(withIdentifier: "currVersion", for: indexPath)
            let version = self.settingsModel.getVersion(index: indexPath.row)
            selectedCell.textLabel?.text = "\(version.versionAbbr), \(version.versionName)"
            selectedCell.detailTextLabel?.text = "\(version.ownerName)"
            selectedCell.accessoryType = UITableViewCellAccessoryType.detailButton // not working
            return selectedCell
        case 4:
            if indexPath.row == 0 {
                return self.searchCell
            } else {
                let otherCell = tableView.dequeueReusableCell(withIdentifier: "currVersion", for: indexPath)
                let version = self.settingsModel.getVersion(index: indexPath.row - 1)
                otherCell.textLabel?.text = "\(version.versionAbbr), \(version.versionName)"
                otherCell.detailTextLabel?.text = "\(version.ownerName)"
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
        // TBD
    }

    // Return true for each row that can be moved
    func tableView(_ tableView: UITableView, canMoveRowAt: IndexPath) -> Bool {
        return (canMoveRowAt.section == 3)
    }
    
    // Commit the row move in the data source
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        // TBD
    }
}
