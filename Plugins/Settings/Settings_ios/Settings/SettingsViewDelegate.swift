//
//  SettingsViewDelegate.swift
//  Settings
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 Short Sands, LLC All rights reserved.
//

import UIKit

class SettingsViewDelegate : NSObject, UITableViewDelegate {
    
    private weak var controller: SettingsViewController?
    private weak var navController: UINavigationController?
    private weak var dataSource: SettingsViewDataSource?
    private let dataModel: SettingsModel?
    private let settingsViewType: SettingsViewType
    private let selectedSection: Int
    private let availableSection: Int
    
    init(controller: SettingsViewController, selectionViewSection: Int) {
        self.controller = controller
        self.navController = controller.navigationController
        self.dataSource = controller.dataSource
        self.dataModel = controller.dataModel
        self.settingsViewType = controller.settingsViewType
        self.selectedSection = selectionViewSection
        self.availableSection = selectionViewSection + 1
        super.init()
    }
    
    deinit {
        print("**** deinit SettingsViewDelegate \(self.settingsViewType) ******")
    }
 
    // Does the same as didSelectRow at, not sure why I could not call it directly.
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.settingsViewType {
        case .primary:
            primaryViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .bible:
            bibleViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .language:
            languageViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .oneLang:
            bibleViewRowSelect(tableView: tableView, indexPath: indexPath)
        }
    }

    // Handle row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.settingsViewType {
        case .primary:
            primaryViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .bible:
            bibleViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .language:
            languageViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .oneLang:
            bibleViewRowSelect(tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func primaryViewRowSelect(tableView: UITableView, indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let tocController = ExternControllerImpl()
                tocController.present(title: NSLocalizedString("Table of Contents", comment: "View title"))
                self.navController?.pushViewController(tocController, animated: true)
            case 1:
                let histController = ExternControllerImpl()
                histController.present(title: NSLocalizedString("History", comment: "View title"))
                self.navController?.pushViewController(histController, animated: true)
            case 2:
                let videoController = ExternControllerImpl()
                videoController.present(title: NSLocalizedString("Videos", comment: "View title"))
                self.navController?.pushViewController(videoController, animated: true)
            default: fatalError("Unknown row \(indexPath.row) in section 0")
            }
        case 1:
            print("Section 1 Font Size Widget.  It is not selectable.")
        case 2:
            switch indexPath.row {
            case 0:
                let bibleController = SettingsViewController(settingsViewType: .bible)
                self.navController?.pushViewController(bibleController, animated: true)
            case 1:
                let languageController = SettingsViewController(settingsViewType: .language)
                self.navController?.pushViewController(languageController, animated: true)
            default: fatalError("Unknown row \(indexPath.row) in section 1")
            }
        case 3:
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
                let infoPageController = InfoPageController()
                self.navController?.pushViewController(infoPageController, animated: true)
            case 3:
                let userMessageController = UserMessageController()
                self.navController?.present(userMessageController, animated: true, completion: nil)
            default:
                print("Unknown row \(indexPath.row) in section 0 in .primary")
            }
        default:
            fatalError("Unknown section \(indexPath.section) in .primary")
        }
    }
    
    private func bibleViewRowSelect(tableView: UITableView, indexPath: IndexPath) {
        if indexPath.section == self.selectedSection {
            if let bible = self.dataModel!.getSelectedBible(row: indexPath.row) {
                HistoryModel.shared.changeBible(bible: bible)
            }
            self.controller?.navigationController?.popToRootViewController(animated: true)
        }
        else if indexPath.section >= self.availableSection {
            let section = indexPath.section - self.availableSection
            if let bible = self.dataModel!.getAvailableBible(section: section, row: indexPath.row) {
                HistoryModel.shared.changeBible(bible: bible)
            }
            self.controller?.dataSource.insertRow(tableView: tableView, indexPath: indexPath)
            // Ensure the language is selected, is added when a Bible is added
            let model = self.dataModel as? BibleModel
            model?.settingsAdapter.ensureLanguageAdded(language: model?.oneLanguage)
            self.controller?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func languageViewRowSelect(tableView: UITableView, indexPath: IndexPath) {
        var language: Language?
        if indexPath.section == self.selectedSection {
            language = self.dataModel!.getSelectedLanguage(row: indexPath.row)
        } else {
            language = self.dataModel!.getAvailableLanguage(row: indexPath.row)
        }
        let oneLang = SettingsViewController(settingsViewType: .oneLang)
        oneLang.oneLanguage = language
        self.controller?.navigationController?.pushViewController(oneLang, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let heading = titleForHeaderInSection(section: section) {
            let font = AppFont.sansSerif(style: .subheadline)
            let rect = CGRect(x: 0, y: font.lineHeight, width: tableView.frame.size.width - 10, height: font.lineHeight)
            let label = UILabel(frame: rect)
            label.font = font
            label.textAlignment = .center
            label.textColor = UIColor.darkGray
            label.text = heading
            return label
        } else {
            return nil
        }
    }
    
    private func titleForHeaderInSection(section: Int) -> String? {
        switch self.settingsViewType {
        case .primary:
            switch section {
            case 0: return nil
            case 1: return nil
            case 2: return NSLocalizedString("Bibles", comment: "Section heading for User selected Bibles")
            case 3: return NSLocalizedString("About", comment: "Section heading for About")
            default: fatalError("Unknown section \(section) in .primary")
            }
        case .bible:
            if section == self.selectedSection {
                return NSLocalizedString("My Bibles", comment: "Section heading for User selected Bibles")
            }
            else if section >= self.availableSection {
                let index = section - self.availableSection
                let locale = self.dataModel!.locales[index]
                let lang = Locale.current.localizedString(forLanguageCode: locale.languageCode ?? "en")
                return lang
            }
            else { return nil }
        case .language:
            if section == self.selectedSection {
                return NSLocalizedString("My Languages", comment: "Section heading for User languages")
            }
            else if section == self.availableSection {
                return NSLocalizedString("More Languages", comment: "Section heading for Other languages")
            }
            else { return nil }
        case .oneLang:
            if section == self.selectedSection {
                return NSLocalizedString("My Bibles", comment: "Section heading for User selected Bibles")
            } else {
                let model = self.dataModel as? BibleModel
                return model?.oneLanguage?.name
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.settingsViewType == .primary && section == 0 {
            let font = AppFont.sansSerif(style: .subheadline)
            return 1.0 * font.lineHeight
        }
        else if self.settingsViewType == .primary && section <= 1 {
            let font = AppFont.sansSerif(style: .subheadline)
            return 1.5 * font.lineHeight
        }
        else {
            let font = AppFont.sansSerif(style: .subheadline)
            return 3 * font.lineHeight
        }
    }

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

