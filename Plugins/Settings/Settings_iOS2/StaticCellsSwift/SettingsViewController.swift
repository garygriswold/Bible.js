//
//  SettingsViewController.swift
//  StaticCellsSwift
//
// http://derpturkey.com/create-a-static-uitableview-without-storyboards/

import Foundation
import UIKit

enum SettingsViewType {
    case primary
    case language
    case version
}

class SettingsViewController: UIViewController {
    
    let settingsViewType: SettingsViewType
    let dataSource: SettingsViewDataSource
    let delegate: SettingsViewDelegate
    var tableView: UITableView!
    
    init(settingsViewType: SettingsViewType) {
        self.settingsViewType = settingsViewType
        let section = (settingsViewType == .primary) ? 3 : 0
        self.dataSource = SettingsViewDataSource(settingsViewType: settingsViewType, selectionViewSection: section)
        self.delegate = SettingsViewDelegate(settingsViewType: settingsViewType, selectionViewSection: section)
        super.init(nibName: nil, bundle: nil)
    }
    
    // This constructor is not used
    required init?(coder: NSCoder) {
        self.settingsViewType = .primary
        self.dataSource = SettingsViewDataSource(settingsViewType: .primary, selectionViewSection: 3)
        self.delegate = SettingsViewDelegate(settingsViewType: .primary, selectionViewSection: 3)
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
            self.title = "Settings"
            self.tableView.register(VersionCell.self, forCellReuseIdentifier: "versionCell")
        case .language:
            self.title = "Languages"
            self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")
        case .version:
            self.title = "Bibles"
            self.tableView.register(VersionCell.self, forCellReuseIdentifier: "versionCell")
        }
        self.tableView.register(SearchCell.self, forCellReuseIdentifier: "searchCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        SearchCell.updatePreferredFontSize()
        
        // set Top Bar items
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                action: #selector(doneHandler))
        //self.saveHandler(sender: nil)
        
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
        tableView.reloadData() // updates preferred font size in table
        SearchCell.updatePreferredFontSize()
    }
    
    //@objc func editHandler(sender: UIBarButtonItem?) {
    //    self.tableView.setEditing(true, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self,
    //                                                             action: #selector(saveHandler))
    //}
    
    //@objc func saveHandler(sender: UIBarButtonItem?) {
    //    self.tableView.setEditing(false, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
    //                                                             action: #selector(editHandler))
    //}
    
    @objc func doneHandler(sender: UIBarButtonItem?) {
        print("Done button clicked")
    }
}

