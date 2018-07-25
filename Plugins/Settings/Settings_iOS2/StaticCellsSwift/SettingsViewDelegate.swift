//
//  SettingsViewDelegate.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC All rights reserved.
//

import Foundation
import UIKit

class SettingsViewDelegate : NSObject, UITableViewDelegate {
    
    deinit {
        print("****** Deinit SettingsViewDelegate ******")
    }
    
    // Keeps non-editable rows from indenting
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt: IndexPath) -> Bool {
        switch shouldIndentWhileEditingRowAt.section {
        case 3: return true
        case 4: return true
        default: return false
        }
    }
 
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCellEditingStyle {
        switch editingStyleForRowAt.section {
        case 3: return UITableViewCellEditingStyle.delete
        case 4: return UITableViewCellEditingStyle.insert
        default: return UITableViewCellEditingStyle.none
        }
    }
 
    // Configure the row selection code for any cells that you want to customize the row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 {
            return true
        } else {
            return false
        }
    }
    
    //
    func tableView(_ tableView: UITableView, moveRowAt: IndexPath, to: IndexPath) {
        
    }
}
