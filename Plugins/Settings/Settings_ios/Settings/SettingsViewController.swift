//
//  SettingsViewController.swift
//  Settings
//

import Foundation
import UIKit

enum SettingsViewType {
    case primary
    case language
}

class SettingsViewController: UIViewController {
    
    let settingsViewType: SettingsViewType
    var searchController: SettingsSearchController?
    var dataModel: SettingsModel!
    var tableView: UITableView!
    var recentContentOffset: CGPoint // Used to restore position when returning to view
    
    private let selectedSection: Int
    private let availableSection: Int
    private var dataSource: SettingsViewDataSource!
    private var delegate: SettingsViewDelegate!
    
    init(settingsViewType: SettingsViewType) {
        self.settingsViewType = settingsViewType
        self.selectedSection = (settingsViewType == .primary) ? 3 : 0
        self.availableSection = self.selectedSection + 1
        self.recentContentOffset = CGPoint(x:0, y: 0)
        
        super.init(nibName: nil, bundle: nil)
        
        if settingsViewType == .language {
            self.searchController = SettingsSearchController(controller: self, selectionViewSection: self.selectedSection)
        }
    }
    
    deinit {
        print("**** deinit SettingsViewController \(settingsViewType) ******")
    }
    
    // This constructor is not used
    required init?(coder: NSCoder) {
        self.settingsViewType = .primary
        self.selectedSection = (settingsViewType == .primary) ? 3 : 0
        self.availableSection = self.selectedSection + 1
        self.recentContentOffset = CGPoint(x:0, y: 0)
        super.init(coder: coder)
    }

    override func loadView() {
        super.loadView()
 
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.grouped)
        self.tableView.allowsSelectionDuringEditing = true
        let barHeight = self.navigationController?.navigationBar.frame.height ?? 44
        self.recentContentOffset = CGPoint(x:0, y: -1 * barHeight)
        print("barHeight = \(barHeight)")
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.tableView)
        let width = self.view.bounds.width
 
        switch self.settingsViewType {
        case .primary:
            self.navigationItem.title = NSLocalizedString("Settings", comment: "Settings view page title")
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\u{FF1c} ", style: .plain, target: self,
                                                                    action: #selector(doneHandler))
        case .language:
            self.navigationItem.title = NSLocalizedString("Languages", comment: "Languages view page title")
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        }
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        AppFont.updateSearchFontSize()
        
        self.tableView.setEditing(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // When UserMessage is dismissed, it has sometimes left behind only the top half of the screen
        self.tableView.frame = UIScreen.main.bounds
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1.0))
        self.tableView.tableHeaderView = label
        
        self.tableView.contentOffset = self.recentContentOffset
        
        switch self.settingsViewType {
        case .primary:
            self.dataModel = BibleModel(availableSection: self.availableSection)
        case .language:
            self.dataModel = LanguageModel(availableSection: self.availableSection)
        }
        self.dataSource = SettingsViewDataSource(controller: self, selectionViewSection: self.selectedSection,
                                                 searchController: self.searchController)
        self.delegate = SettingsViewDelegate(controller: self, selectionViewSection: self.selectedSection)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(preferredContentSizeChanged(note:)),
                           name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if self.settingsViewType == .language {
            self.searchController?.viewAppears(dataModel: self.dataModel)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.recentContentOffset = self.tableView.contentOffset;
        super.viewWillDisappear(animated)
        
        //Must remove, or this view will scroll because of keyboard actions in upper view.
        let notify = NotificationCenter.default
        notify.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        notify.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notify.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /**
     * iOS 10 includes: .adjustsFontForContentSizeCategory, which can be set to each label to
     * perform automatic text size adjustment
    */
    @objc func preferredContentSizeChanged(note: NSNotification) {
        AppFont.userFontDelta = 1.0
        tableView.reloadData() // updates preferred font size in table
        AppFont.updateSearchFontSize()
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardInfo: Dictionary = note.userInfo {
            if let keyboardRect: CGRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = keyboardRect.minY
                let bounds = UIScreen.main.bounds
                self.tableView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: keyboardTop)
            }
        }
        self.tableView.scrollToRow(at: IndexPath(item: 0, section: self.availableSection), at: .top, animated: true)
        //self.editHandler(sender: nil)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.tableView.frame = UIScreen.main.bounds
        //self.saveHandler(sender: nil)
    }
/*
    @objc func editHandler(sender: UIBarButtonItem?) {
        self.tableView.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                 action: #selector(saveHandler))
    }
    
    @objc func saveHandler(sender: UIBarButtonItem?) {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
    }
*/
    @objc func doneHandler(sender: UIBarButtonItem?) {
        print("Settings Done button clicked")
    }
}

