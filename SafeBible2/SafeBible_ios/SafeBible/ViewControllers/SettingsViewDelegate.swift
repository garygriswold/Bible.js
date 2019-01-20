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
        case .bible:
            bibleViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .language:
            languageViewRowSelect(tableView: tableView, indexPath: indexPath)
        case .oneLang:
            bibleViewRowSelect(tableView: tableView, indexPath: indexPath)
        }
    }
    
    private func bibleViewRowSelect(tableView: UITableView, indexPath: IndexPath) {
        if indexPath.section == self.selectedSection {
            if let bible = self.dataModel!.getSelectedBible(row: indexPath.row) {
                HistoryModel.shared.changeBible(bible: bible)
            }
            NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                            object: HistoryModel.shared.current())
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
            NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                            object: HistoryModel.shared.current())
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
        SettingsViewController.push(settingsViewType: .oneLang, controller: self.controller,
                                    language: language)
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
        let font = AppFont.sansSerif(style: .subheadline)
        return 3 * font.lineHeight
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
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCell.EditingStyle {
        if editingStyleForRowAt.section == selectedSection {
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
}
