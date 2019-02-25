//
//  SettingsViewController.swift
//  Settings
//

import UIKit

enum SettingsViewType {
    case bible
    case oneLang
}

class SettingsViewController: AppViewController {
    
    static func push(settingsViewType: SettingsViewType, controller: UIViewController?, language: Language?) {
        let bibleController = SettingsViewController(settingsViewType: settingsViewType)
        bibleController.oneLanguage = language
        controller?.navigationController?.pushViewController(bibleController, animated: true)
    }
    
    let settingsViewType: SettingsViewType
    var dataModel: SettingsModel!
    var tableView: UITableView!
    var oneLanguage: Language? // Used only when settingsViewType == .oneLang
    var recentContentOffset: CGPoint // Used to restore position when returning to view
    var editModeOnOff = false // Set to true in order to have edit button in top right
    
    private let selectedSection: Int
    private let availableSection: Int
    var dataSource: SettingsViewDataSource!
    private var delegate: SettingsViewDelegate!
    
    init(settingsViewType: SettingsViewType) {
        self.settingsViewType = settingsViewType
        self.selectedSection = 0
        self.availableSection = self.selectedSection + 1
        self.recentContentOffset = CGPoint(x:0, y: 0)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("SettingsViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit SettingsViewController \(settingsViewType) ******")
    }

    override func loadView() {
        super.loadView()
 
        // create Table view
        self.tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.grouped)
        self.tableView.backgroundColor = AppFont.groupTableViewBackground
        self.tableView.allowsSelectionDuringEditing = true
        let barHeight = self.navigationController?.navigationBar.frame.height ?? 44
        self.recentContentOffset = CGPoint(x:0, y: -1 * barHeight)
        self.view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        let width = self.view.bounds.width
        switch self.settingsViewType {
        case .bible:
            self.navigationItem.title = NSLocalizedString("Bibles", comment: "Bibles view page title")
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        case .oneLang:
            /// This should be a pre- translated language name
            self.navigationItem.title = NSLocalizedString("Bibles", comment: "Bibles view page title")
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        }
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
        
        self.tableView.contentOffset = self.recentContentOffset
        
        switch self.settingsViewType {
        case .bible:
            self.dataModel = BibleModel(availableSection: self.availableSection, language: nil,
                                        selectedOnly: false)
        case .oneLang:
            self.dataModel = BibleModel(availableSection: self.availableSection,
                                        language: self.oneLanguage,
                                        selectedOnly: false)
        }
        self.dataSource = SettingsViewDataSource(controller: self, selectionViewSection: self.selectedSection,
                                                 searchController: nil)
        self.delegate = SettingsViewDelegate(controller: self, selectionViewSection: self.selectedSection)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.recentContentOffset = self.tableView.contentOffset;
        super.viewWillDisappear(animated)
    }
    
    @objc override func preferredContentSizeChanged(note: NSNotification) {
        super.preferredContentSizeChanged(note: note)

        tableView.reloadData() // updates preferred font size in table
    }
}

