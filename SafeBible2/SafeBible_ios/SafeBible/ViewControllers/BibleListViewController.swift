//
//  SettingsViewController.swift
//  Settings
//

import UIKit

enum SettingsViewType {
    case bible
    case oneLang
}

class BibleListViewController: AppSettingsViewController {
    
    static func push(settingsViewType: SettingsViewType, controller: UIViewController?, language: Language?) {
        let bibleController = BibleListViewController(settingsViewType: settingsViewType)
        bibleController.oneLanguage = language
        controller?.navigationController?.pushViewController(bibleController, animated: true)
    }
    
    let settingsViewType: SettingsViewType
    var oneLanguage: Language? // Used only when settingsViewType == .oneLang
    
    init(settingsViewType: SettingsViewType) {
        self.settingsViewType = settingsViewType
        super.init(selectedSection: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("BibleListViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit BibleListViewController \(settingsViewType) ******")
    }

    override func loadView() {
        super.loadView()
        self.tableView.allowsSelectionDuringEditing = true
        
        let width = self.view.bounds.width
        self.navigationItem.title = NSLocalizedString("Bibles", comment: "Bibles view page title")
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")

        self.tableView.setEditing(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
        
        // When UserMessage is dismissed, it has sometimes left behind only the top half of the screen
        self.tableView.frame = self.view.bounds
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1.0))
        self.tableView.tableHeaderView = label
        
        switch self.settingsViewType {
        case .bible:
            self.dataModel = BibleModel(availableSection: self.availableSection, language: nil,
                                        selectedOnly: false)
        case .oneLang:
            self.dataModel = BibleModel(availableSection: self.availableSection,
                                        language: self.oneLanguage,
                                        selectedOnly: false)
        }
        self.tableView.dataSource = self
    }
    
    //
    // DataSource
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.settingsViewType {
        case .bible: return 1 + self.dataModel!.availableCount
        case .oneLang: return 2
        }
    }
    
    // Return the number of rows for each section in your static table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.settingsViewType {
        case .bible:
            switch section {
            case 0: return self.dataModel!.selectedCount
            default:
                let index = section - 1
                if let bibleModel = self.dataModel as? BibleModel {
                    return bibleModel.getAvailableBibleCount(section: index)
                } else {
                    return 0
                }
            }
        case .oneLang:
            switch section {
            case 0: return self.dataModel!.selectedCount
            case 1:
                if let bibleModel = self.dataModel as? BibleModel {
                    return bibleModel.getAvailableBibleCount(section: 0)
                } else {
                    return 0
                }
            default: fatalError("Unknown section \(section) in .oneLang")
            }
        }
    }
    
    // Return the row cell for the corresponding section and row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.settingsViewType {
        case .bible:
            switch indexPath.section {
            case 0:
                return self.dataModel!.selectedCell(tableView: tableView, indexPath: indexPath)
            default:
                return self.dataModel!.availableCell(tableView: tableView, indexPath: indexPath,
                                                     inSearch: false)
            }
        case .oneLang:
            switch indexPath.section {
            case 0:
                return self.dataModel!.selectedCell(tableView: tableView, indexPath: indexPath)
            case 1:
                return self.dataModel!.availableCell(tableView: tableView, indexPath: indexPath,
                                                     inSearch: false)
            default: fatalError("Unknown section \(indexPath.section) in .oneLang")
            }
        }
    }
    
    //
    // Delegate
    //
    
    // Handle row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == self.selectedSection {
            if let bible = self.dataModel!.getSelectedBible(row: indexPath.row) {
                HistoryModel.shared.changeBible(bible: bible)
            }
            NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                            object: HistoryModel.shared.current())
            self.navigationController?.popToRootViewController(animated: true)
        }
        else if indexPath.section >= self.availableSection {
            let isCompare = AppDelegate.findRootController(controller: self) is CompareViewController
            let section = indexPath.section - self.availableSection
            if let bible = self.dataModel!.getAvailableBible(section: section, row: indexPath.row) {
                if isCompare {
                    NotificationCenter.default.post(name: ReaderPagesController.NEW_COMPARE,
                                                    object: bible)
                } else {
                    HistoryModel.shared.changeBible(bible: bible)
                    NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                                    object: HistoryModel.shared.current())
                }
            }
            self.insertRow(tableView: tableView, indexPath: indexPath)
            // Ensure the language is selected, is added when a Bible is added
            let model = self.dataModel as? BibleModel
            model?.settingsAdapter.ensureLanguageAdded(language: model?.oneLanguage)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func titleForHeaderInSection(section: Int) -> String? {
        switch self.settingsViewType {
        case .bible:
            if section == self.selectedSection {
                return NSLocalizedString("My Bibles", comment: "Section heading for User selected Bibles")
            }
            else if section >= self.availableSection {
                let index = section - self.availableSection
                let locale = self.dataModel!.locales[index]
                return locale.localized
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
}


