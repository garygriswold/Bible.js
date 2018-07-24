//
//  SettingsViewController.swift
//  StaticCellsSwift
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    var reviewCell: UITableViewCell = UITableViewCell()
    let feedbackCell: UITableViewCell = UITableViewCell()
    var shareCell: UITableViewCell = UITableViewCell()
    
    let cellBackground = UIColor.white
        
    override func loadView() {
        super.loadView()
        
        // set the view title
        self.title = "Settings"
        
        // reviewCell, section 0, row 0
        self.reviewCell.backgroundColor = cellBackground
        self.reviewCell.textLabel?.text = "Write A Review"
        self.reviewCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // feedbackCell, section 0, row 1
        self.feedbackCell.backgroundColor = cellBackground
        self.feedbackCell.textLabel?.text = "Send Us Feedback"
        self.feedbackCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // construct share cell, section 1, row 0
        self.shareCell.textLabel?.text = "Share with Friends"
        self.shareCell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.shareCell.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    // Return the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Customize the section headings for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return "Social"
        default: fatalError("Unknown section")
        }
    }
    
    // Return the number of rows for each section in your static table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2    // section 0 has 2 rows
        case 1: return 1    // section 1 has 1 row
        default: fatalError("Unknown number of sections")
        }
    }
    
    // Return the row for the corresponding section and row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return self.reviewCell
            case 1: return self.feedbackCell
            default: fatalError("Unknown row in section 0")
            }
        case 1:
            switch indexPath.row {
            case 0: return self.shareCell       // section 1, row 0 is the share option
            default: fatalError("Unknown row in section 1")
            }
        default: fatalError("Unknown section")
        }
    }
    
    // Configure the row selection code for any cells that you want to customize the row selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            break
        case 1:
            switch indexPath.row {
            case 0:
                
                // toggle check mark
                if self.shareCell.accessoryType == UITableViewCellAccessoryType.none {
                    self.shareCell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    self.shareCell.accessoryType = UITableViewCellAccessoryType.none
                }
            default:
                break
            }
        default:
            break
        }
    }
}
