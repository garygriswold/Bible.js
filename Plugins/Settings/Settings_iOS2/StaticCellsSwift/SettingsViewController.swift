//
//  SettingsViewController.swift
//  StaticCellsSwift
//
// http://derpturkey.com/create-a-static-uitableview-without-storyboards/

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    let reviewCell = UITableViewCell()
    let feedbackCell = UITableViewCell()
    let textSliderCell = UITableViewCell()
    let textDisplayCell = UITableViewCell()
    let languagesCell = UITableViewCell()
    let versionsCell = UITableViewCell() // This is placeholder
    
    let cellBackground = UIColor.white
        
    override func loadView() {
        super.loadView()
        
        // set the view title
        self.title = "Settings"
        
        if let tableView = self.view as? UITableView {
            tableView.allowsMultipleSelectionDuringEditing = false // This might not be needed, not sure
        }
        
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
        
        // textDisplay, section 1, row 1
        self.textDisplayCell.backgroundColor = cellBackground
        self.textDisplayCell.textLabel?.text = "For God so loved TBD"
        
        // languages, section 2, row 0
        self.languagesCell.backgroundColor = cellBackground
        self.languagesCell.textLabel?.text = "Languages"
        self.languagesCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        // versions, section 3, row 0
        self.versionsCell.backgroundColor = cellBackground
        self.versionsCell.textLabel?.text = "KJV, King James Version"
        //self.versionsCell.editingAccessoryType = UITableViewCellEditingStyle.delete
        //self.versionsCell.editingStyle = UITableViewCellEditingStyle.delete
        self.versionsCell.showsReorderControl = true
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "currVersion")
        
    }
    
    // Return the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    // Customize the section headings for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 3: return "Bibles"
        default: return nil
        }
    }
    
    // Return the number of rows for each section in your static table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        case 2: return 1
        case 3: return 3
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
            //switch indexPath.row {
            //case 0: return self.versionsCell
            //default: fatalError("Unknown row \(indexPath.row) in section 3")
            //}
            let cell = tableView.dequeueReusableCell(withIdentifier: "currVersion", for: indexPath)
            cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
            return cell
        default: fatalError("Unknown section")
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCellEditingStyle {
        if editingStyleForRowAt.section == 3 {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.none
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
                break
                // toggle check mark
                //if self.shareCell.accessoryType == UITableViewCellAccessoryType.none {
                //    self.shareCell.accessoryType = UITableViewCellAccessoryType.checkmark
                //} else {
                //    self.shareCell.accessoryType = UITableViewCellAccessoryType.none
                //}
            default:
                break
            }
        default:
            break
        }
    }
    
    // This should not be needed. It is only needed to turn off moving
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt: IndexPath, to: IndexPath) {
        
    }
}
