//
//  LanguageListViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 2/24/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class LanguageListViewController: AppSettingsViewController, UITableViewDataSource {
    
    static func push(controller: UIViewController?) {
        let langController = LanguageListViewController()
        controller?.navigationController?.pushViewController(langController, animated: true)
    }
    
    init() {
        super.init(selectedSection: 0)
        self.searchController = SettingsSearchController(controller: self,
                                                        selectionViewSection: self.selectedSection)
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
            if self.searchController?.isSearching() ?? false {
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
    
    //
    // Delegate
    //
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var language: Language?
        if indexPath.section == self.selectedSection {
            language = self.dataModel!.getSelectedLanguage(row: indexPath.row)
        } else {
            language = self.dataModel!.getAvailableLanguage(row: indexPath.row)
        }
        SettingsViewController.push(settingsViewType: .oneLang, controller: self,
                                    language: language)
    }
  
    override func titleForHeaderInSection(section: Int) -> String? {
        if section == self.selectedSection {
            return NSLocalizedString("My Languages", comment: "Section heading for User languages")
        }
        else if section == self.availableSection {
            return NSLocalizedString("More Languages", comment: "Section heading for Other languages")
        }
        else { return nil }
    }
}
