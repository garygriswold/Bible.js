//
//  SettingsViewController.swift
//  StaticCellsSwift
//

import Foundation
import UIKit

enum SettingsViewType {
    case primary
    case language
    case version
}

class SettingsViewController: UIViewController {
    
    let settingsViewType: SettingsViewType
    var dataModel: SettingsModelInterface!
    var dataSource: SettingsViewDataSource!
    var delegate: SettingsViewDelegate!
    var tableView: UITableView!
    
    init(settingsViewType: SettingsViewType) {
        self.settingsViewType = settingsViewType
        super.init(nibName: nil, bundle: nil)
    }
    
    // This constructor is not used
    required init?(coder: NSCoder) {
        self.settingsViewType = .primary
        super.init(coder: coder)
    }

    override func loadView() {
        super.loadView()
 
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.grouped)
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.setEditing(true, animated: false)
        self.view = self.tableView
 
        switch self.settingsViewType {
        case .primary:
            self.navigationItem.title = "Settings"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\u{FF1c} Bible", style: .done, target: self,
                                                                    action: #selector(doneHandler))
            self.dataModel = VersionModel()
            self.tableView.register(VersionCell.self, forCellReuseIdentifier: "versionCell")
        case .language:
            self.navigationItem.title = "Languages"
            self.dataModel = LanguageModel()
            self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")
        case .version:
            self.navigationItem.title = "Bibles"
            self.dataModel = VersionModel()
            self.tableView.register(VersionCell.self, forCellReuseIdentifier: "versionCell")
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        SearchCell.updateFontSize()
        
        self.saveHandler(sender: nil)
        
        let section = (settingsViewType == .primary) ? 3 : 0
        self.dataSource = SettingsViewDataSource(controller: self, selectionViewSection: section)
        self.delegate = SettingsViewDelegate(controller: self, selectionViewSection: section)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(preferredContentSizeChanged(note:)),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    /**
     * iOS 10 includes: .adjustsFontForContentSizeCategory, which can be set to each label to
     * perform automatic text size adjustment
    */
    @objc func preferredContentSizeChanged(note: NSNotification) {
        AppFont.userFontDelta = 1.0
        tableView.reloadData() // updates preferred font size in table
        SearchCell.updateFontSize()
    }
    
    @objc func editHandler(sender: UIBarButtonItem?) {
        self.tableView.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                                                 action: #selector(saveHandler))
    }
    
    @objc func saveHandler(sender: UIBarButtonItem?) {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
    }
    
    @objc func doneHandler(sender: UIBarButtonItem?) {
        print("Settings Done button clicked")
    }
}

