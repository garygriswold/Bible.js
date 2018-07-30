//
//  LanguageViewDelegate.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class LanguageViewDelegate : NSObject, UITableViewDelegate {
    
    deinit {
        print("****** Deinit SettingsViewDelegate ******")
    }
    
    //func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //return UITableViewAutomaticDimension
    //}
    
    //func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {}
    
    // Define edit actions for a row swipe
    //func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {}
    
    //func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {}
    
    // Handle row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            // Must get detail
            print("Selected \(indexPath.row) clicked")
        case 1:
            // Must perform search
            print("Search selected")
        case 2:
            // Must get detail
            print("Other \(indexPath.row) clicked")
        default:
            print("Unknown section \(indexPath.row)")
        }
    }
    
    // This is required for heightForHeaderInSection to work
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    // This is required for heightForFooterInSection to work
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 2) ? 0.0 : -1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 1) ? 0.0 : -1.0
    }
    
    // Called when swipe is used to begin editing
    //func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    
    // Called when editing is ended that was initiated by swipe
    //func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    
    // Identifies Add and Delete Rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCellEditingStyle {
        switch editingStyleForRowAt.section {
        case 0: return UITableViewCellEditingStyle.delete
        case 2: return UITableViewCellEditingStyle.insert
        default: return UITableViewCellEditingStyle.none
        }
    }
    
    //func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    //    return (indexPath.section == 3) ? "Remove" : nil
    //}
    
    // Keeps non-editable rows from indenting
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt: IndexPath) -> Bool {
        switch shouldIndentWhileEditingRowAt.section {
        case 0: return true
        case 2: return true
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


