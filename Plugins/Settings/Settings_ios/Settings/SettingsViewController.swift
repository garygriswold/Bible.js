//
//  SettingsViewController.swift
//  Settings
//

import Foundation
import UIKit

enum SettingsViewType {
    case primary
    case language
    case bible
}

class SettingsViewController: UIViewController {
    
    let settingsViewType: SettingsViewType
    var dataModel: SettingsModelInterface!
    var tableView: UITableView!
    var language: Language? // Used only when SettingsViewType is .bible
    
    private let selectedSection: Int
    private let availableSection: Int
    private var dataSource: SettingsViewDataSource!
    private var delegate: SettingsViewDelegate!
    
    
    init(settingsViewType: SettingsViewType) {
        self.settingsViewType = settingsViewType
        self.selectedSection = (settingsViewType == .primary) ? 3 : 0
        self.availableSection = self.selectedSection + 1
        super.init(nibName: nil, bundle: nil)
    }
    
    // This constructor is not used
    required init?(coder: NSCoder) {
        self.settingsViewType = .primary
        self.selectedSection = (settingsViewType == .primary) ? 3 : 0
        self.availableSection = self.selectedSection + 1
        super.init(coder: coder)
    }

    override func loadView() {
        super.loadView()
 
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.grouped)
        self.tableView.allowsSelectionDuringEditing = true
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.tableView)
        let width = self.view.bounds.width
 
        switch self.settingsViewType {
        case .primary:
            self.navigationItem.title = "Settings"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "\u{FF1c} Read", style: .done, target: self,
                                                                    action: #selector(doneHandler))
            self.dataModel = BibleModel(language: nil)
            self.tableView.register(BibleCell.self, forCellReuseIdentifier: "bibleCell")
        case .language:
            self.navigationItem.title = "Languages"
            self.dataModel = LanguageModel()
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
            self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")
        case .bible:
            self.navigationItem.title = "Bibles"
            self.dataModel = BibleModel(language: self.language)
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
            self.tableView.register(BibleCell.self, forCellReuseIdentifier: "bibleCell")
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        AppFont.updateSearchFontSize()
        
        self.saveHandler(sender: nil)
        
        self.dataSource = SettingsViewDataSource(controller: self, selectionViewSection: self.selectedSection)
        self.delegate = SettingsViewDelegate(controller: self, selectionViewSection: self.selectedSection)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(preferredContentSizeChanged(note:)),
                           name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        self.editHandler(sender: nil)
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.tableView.frame = UIScreen.main.bounds
        self.saveHandler(sender: nil)
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

