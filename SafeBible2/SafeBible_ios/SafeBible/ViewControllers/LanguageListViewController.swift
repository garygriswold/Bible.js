//
//  LanguageListViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 2/24/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class LanguageListViewController: AppTableViewController, UITableViewDataSource {
    
    static func push(controller: UIViewController?) {
        let langController = LanguageListViewController()
        controller?.navigationController?.pushViewController(langController, animated: true)
    }
    
    var searchController: SettingsSearchController?
    var dataModel: SettingsModel!
    
    private let selectedSection: Int
    private let availableSection: Int
    
    init() {
        self.selectedSection = 0
        self.availableSection = self.selectedSection + 1
        
        super.init(nibName: nil, bundle: nil)
        self.searchController = SettingsSearchController(controller: self, selectionViewSection: self.selectedSection)
    }
    
    required init?(coder: NSCoder) {
        fatalError("LanguageListViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit LanguageListViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.tableView.allowsSelectionDuringEditing = true
        
        let width = self.view.bounds.width
        self.navigationItem.title = NSLocalizedString("Languages", comment: "Languages view page title")
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        AppFont.updateSearchFontSize()
        
        self.tableView.setEditing(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
        
        // When UserMessage is dismissed, it has sometimes left behind only the top half of the screen
        self.tableView.frame = self.view.bounds
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1.0))
        self.tableView.tableHeaderView = label
        
        //self.tableView.contentOffset = self.recentContentOffset
        
        self.dataModel = LanguageModel(availableSection: self.availableSection)
        self.tableView.dataSource = self
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.searchController?.viewAppears(dataModel: self.dataModel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.recentContentOffset = self.tableView.contentOffset;
        super.viewWillDisappear(animated)
        
        //Must remove, or this view will scroll because of keyboard actions in upper view.
        let notify = NotificationCenter.default
        notify.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardInfo: Dictionary = note.userInfo {
            if let keyboardRect: CGRect = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = keyboardRect.minY
                let bounds = self.view.bounds
                self.tableView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: keyboardTop)
            }
        }
        self.tableView.scrollToRow(at: IndexPath(item: 0, section: self.availableSection), at: .top,
                                   animated: true)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.tableView.frame = self.view.bounds
    }
    
    //
    // DataSource
    //
    
    // Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Return the number of rows for each section in your static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return self.dataModel!.selectedCount
        case 1:
            if self.searchController!.isSearching() {
                return self.dataModel!.filteredCount
            } else {
                return self.dataModel!.availableCount
            }
        default: fatalError("Unknown section \(section) in .language ")
        }
    }
    
    // Return the row cell for the corresponding section and row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return self.dataModel!.selectedCell(tableView: tableView, indexPath: indexPath)
        case 1:
            return self.dataModel!.availableCell(tableView: tableView, indexPath: indexPath, inSearch: self.searchController?.isSearching() ?? false)
        default: fatalError("Unknown section \(indexPath.section) in .language")
        }
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.deleteRow(tableView: tableView, indexPath: indexPath)
        } else if editingStyle == UITableViewCell.EditingStyle.insert {
            self.insertRow(tableView: tableView, indexPath: indexPath)
        }
    }
    
    func deleteRow(tableView: UITableView, indexPath: IndexPath) {
        let destination = self.dataModel!.findAvailableInsertIndex(selectedIndex: indexPath)
        self.dataModel!.moveSelectedToAvailable(source: indexPath,
                                                destination: destination,
                                                inSearch: self.searchController?.isSearching() ?? false)
        tableView.moveRow(at: indexPath, to: destination)
        self.searchController?.updateSearchResults()
    }
    
    func insertRow(tableView: UITableView, indexPath: IndexPath) {
        let length = self.dataModel!.selectedCount
        let destination = IndexPath(item: length, section: self.selectedSection)
        self.dataModel!.moveAvailableToSelected(source: indexPath,
                                                destination: destination,
                                                inSearch: self.searchController?.isSearching() ?? false)
        tableView.moveRow(at: indexPath, to: destination)
        
        // When we move a language from available to selected, then select initial versions
        if let model = self.dataModel as? LanguageModel {
            if let language = model.getSelectedLanguage(row: destination.row) {
                let initial = BibleInitialSelect(adapter: model.settingsAdapter)
                let bibles = initial.getBiblesSelected(locales: [language.locale])
                model.settingsAdapter.addBibles(bibles: bibles)
            }
        }
    }
    
    // Return true for each row that can be moved
    func tableView(_ tableView: UITableView, canMoveRowAt: IndexPath) -> Bool {
        return (canMoveRowAt.section == self.selectedSection)
    }
    
    // Commit the row move in the data source
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        self.dataModel!.moveSelected(source: sourceIndexPath.row, destination: destinationIndexPath.row)
    }
    
    //
    // Delegate
    //
    
    // Does the same as didSelectRow at, not sure why I could not call it directly.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //languageViewRowSelect(tableView: tableView, indexPath: indexPath)
        var language: Language?
        if indexPath.section == self.selectedSection {
            language = self.dataModel!.getSelectedLanguage(row: indexPath.row)
        } else {
            language = self.dataModel!.getAvailableLanguage(row: indexPath.row)
        }
        SettingsViewController.push(settingsViewType: .oneLang, controller: self,
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
        if section == self.selectedSection {
            return NSLocalizedString("My Languages", comment: "Section heading for User languages")
        }
        else if section == self.availableSection {
            return NSLocalizedString("More Languages", comment: "Section heading for Other languages")
        }
        else { return nil }
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


