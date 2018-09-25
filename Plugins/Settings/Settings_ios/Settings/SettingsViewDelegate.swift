//
//  SettingsViewDelegate.swift
//  Settings
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SettingsViewDelegate : NSObject, UITableViewDelegate {
    
    private weak var navController: UINavigationController?
    private let dataModel: SettingsModel
    private let settingsViewType: SettingsViewType
    private let selectedSection: Int
    private let availableSection: Int
    
    init(controller: SettingsViewController, selectionViewSection: Int) {
        self.navController = controller.navigationController
        self.dataModel = controller.dataModel
        self.settingsViewType = controller.settingsViewType
        self.selectedSection = selectionViewSection
        self.availableSection = selectionViewSection + 1
        super.init()
    }
    
    deinit {
        print("**** deinit SettingsViewDelegate \(self.settingsViewType) ******")
    }
    
    //func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //    return UITableViewAutomaticDimension
    //}
    
    //func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {}
    
    // Define edit actions for a row swipe
    //func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {}
 
    // Does the same as didSelectRow at, not sure why I could not call it directly.
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.settingsViewType == .primary {
            primaryViewRowSelect(tableView: tableView, indexPath: indexPath)
        }
    }

    // Handle row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.settingsViewType == .primary {
            primaryViewRowSelect(tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func primaryViewRowSelect(tableView: UITableView, indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                guard let reviewURL = URL(string: "https://itunes.apple.com/app/id1073396349?action=write-review")
                else { fatalError("Expected a valid URL") }
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                // I have also tried to use WKWebView to access itunes, but it requires User AppleId
                // login credentials.
            case 1:
                let feedbackController = FeedbackViewController()
                self.navController?.pushViewController(feedbackController, animated: true)
            case 2:
                let userMessageController = UserMessageController()
                self.navController?.present(userMessageController, animated: true, completion: nil)
            default:
                print("Unknown row \(indexPath.row) in section 0")
            }
        case 1:
            print("Section 1 Font Size Widget.  It is not selectable.")
        case 2:
            let languageController = SettingsViewController(settingsViewType: .language)
            self.navController?.pushViewController(languageController, animated: true)
        default:
            bibleViewRowSelect(tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func bibleViewRowSelect(tableView: UITableView, indexPath: IndexPath) {
        if indexPath.section  == self.selectedSection {
            if let bible = self.dataModel.getSelectedBible(row: indexPath.row) {
                let detailController = BibleDetailViewController(bible: bible)
                self.navController?.pushViewController(detailController, animated: true)
            }
        }
        else if indexPath.section >= self.availableSection {
            let bibleModel = self.dataModel as! BibleModel
            if let bible = bibleModel.getAvailableBible(section: (indexPath.section - 4), row: indexPath.row) {
                let detailController = BibleDetailViewController(bible: bible)
                self.navController?.pushViewController(detailController, animated: true)
            }
        }
    }

    // This must return nil in order for heightForHeaderInSection to work
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let heading = titleForHeaderInSection(section: section) {
            let font = AppFont.sansSerif(style: .subheadline)
            let rect = CGRect(x: 0, y: font.lineHeight, width: tableView.frame.size.width - 10, height: font.lineHeight)
            let view = UIView(frame: rect)
            let label = UILabel(frame: rect)
            label.font = font
            label.textAlignment = .center
            label.textColor = UIColor.darkGray
            label.text = heading
            view.addSubview(label)
            return view
        } else {
            return nil
        }
    }
    
    private func titleForHeaderInSection(section: Int) -> String? {
        switch self.settingsViewType {
        case .primary:
            if section == self.selectedSection {
                return NSLocalizedString("My Bibles", comment: "Section heading for User selected Bibles")
            }
            else if section >= self.availableSection {
                let index = section - 4
                let locale = self.dataModel.locales[index]
                let lang = Locale.current.localizedString(forLanguageCode: locale.languageCode ?? "en")
                return lang
            }
            else {
                return nil
            }
        case .language:
            if section == self.selectedSection {
                return NSLocalizedString("My Languages", comment: "Section heading for User languages")
            }
            else if section == self.availableSection {
                return NSLocalizedString("More Languages", comment: "Section heading for Other languages")
            }
            else { return nil }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.settingsViewType == .primary && section == 0 { return 0.0 }
        else if self.settingsViewType == .primary && section < self.selectedSection {
            let font = AppFont.sansSerif(style: .subheadline)
            return 1.5 * font.lineHeight
        }
        else {
            let font = AppFont.sansSerif(style: .subheadline)
            return 3 * font.lineHeight
        }
    }

    // This must return nil in order for heightForFooterInSection to work
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == self.availableSection) ? -1.0 : 0.0
    }

    // Called when swipe is used to begin editing
    //func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    
    // Called when editing is ended that was initiated by swipe
    //func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    
    // Identifies Add and Delete Rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCellEditingStyle {
        if editingStyleForRowAt.section == selectedSection {
            return UITableViewCellEditingStyle.delete
        }
        else if editingStyleForRowAt.section >= self.availableSection {
            return UITableViewCellEditingStyle.insert
        }
        else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if indexPath.section == selectedSection {
            return NSLocalizedString("Remove", comment: "Red Delete Button text")
        } else {
            return nil
        }
    }
    
    // Keeps non-editable rows from indenting
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt: IndexPath) -> Bool {
        return (shouldIndentWhileEditingRowAt.section >= self.selectedSection)
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

