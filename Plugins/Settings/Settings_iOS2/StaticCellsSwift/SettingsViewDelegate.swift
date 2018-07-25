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
    
    //func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {}
    
    //func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {}
    
    // Define edit actions for a row swipe
    //func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {}
    
    //func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {}
    
    // Handle row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // Must call Apple review widget
                print("Write a review selected")
            case 1:
                // Must go to feedback page
                print("Send us feedback selected")
            default:
                print("Unknown row \(indexPath.row) in section 0")
            }
        case 1:
            switch indexPath.row {
            case 0:
                // Must resize text
                print("Text size widget selected")
            case 1:
                // Should disable selection
                print("Text size demo selected")
            default:
                print("Unknown row \(indexPath.row) in section 1")
            }
        case 2:
            // Must navigate to language selection view
            print("Languages selected")
        case 3:
            // Must get detail
            print("Selected version \(indexPath.row) selected")
        case 4:
            if indexPath.row == 0 {
                // Must perform search
                print("Search selected")
            } else {
                // Must get detail
                print("Other version \(indexPath.row) selected")
            }
        default:
            print("Unknown section \(indexPath.row)")
        }
    }
    
    // Called when swipe is used to begin editing
    //func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    
    // Called when editing is ended that was initiated by swipe
    //func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    
    // Identifies Add and Delete Rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCellEditingStyle {
        switch editingStyleForRowAt.section {
        case 3: return UITableViewCellEditingStyle.delete
        case 4: return UITableViewCellEditingStyle.insert
        default: return UITableViewCellEditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return (indexPath.section == 3) ? "Remove" : nil
    }
    
    // Keeps non-editable rows from indenting
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt: IndexPath) -> Bool {
        switch shouldIndentWhileEditingRowAt.section {
        case 3: return true
        case 4: return true
        default: return false
        }
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
    
    // Called when a cell is removed from the view
    //func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    //func tableView(_ tableView: UITableView,
    //               leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    
    //func tableView(_ tableView: UITableView,
    //               trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
}
