//
//  SettingsViewController.swift
//  Settings
//

import UIKit

enum SettingsViewType {
    case primary
    case bible
    case language
    case oneLang
}

class SettingsViewController: AppViewController {
    
    static func push(settingsViewType: SettingsViewType, controller: UIViewController?, language: Language?) {
        let bibleController = SettingsViewController(settingsViewType: settingsViewType)
        bibleController.oneLanguage = language
        controller?.navigationController?.pushViewController(bibleController, animated: true)
    }
    
    let settingsViewType: SettingsViewType
    var searchController: SettingsSearchController?
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
        
        if settingsViewType == .language {
            self.searchController = SettingsSearchController(controller: self, selectionViewSection: self.selectedSection)
        }
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
        case .primary:
            self.navigationItem.title = NSLocalizedString("Menu", comment: "Menu view page title")
        case .bible:
            self.navigationItem.title = NSLocalizedString("Bibles", comment: "Bibles view page title")
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        case .language:
            self.navigationItem.title = NSLocalizedString("Languages", comment: "Languages view page title")
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        case .oneLang:
            /// This should be a pre- translated language name
            self.navigationItem.title = NSLocalizedString("Bibles", comment: "Bibles view page title")
            self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        }
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        AppFont.updateSearchFontSize()
        
        if self.editModeOnOff {
            self.saveHandler(sender: nil)
        } else {
            self.tableView.setEditing(true, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // When UserMessage is dismissed, it has sometimes left behind only the top half of the screen
        self.tableView.frame = self.view.bounds
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1.0))
        self.tableView.tableHeaderView = label
        
        self.tableView.contentOffset = self.recentContentOffset
        
        switch self.settingsViewType {
        case .primary:
            self.dataModel = nil
        case .bible:
            self.dataModel = BibleModel(availableSection: self.availableSection, language: nil,
                                        selectedOnly: false)
        case .language:
            self.dataModel = LanguageModel(availableSection: self.availableSection)
        case .oneLang:
            self.dataModel = BibleModel(availableSection: self.availableSection,
                                        language: self.oneLanguage,
                                        selectedOnly: false)
        }
        self.dataSource = SettingsViewDataSource(controller: self, selectionViewSection: self.selectedSection,
                                                 searchController: self.searchController)
        self.delegate = SettingsViewDelegate(controller: self, selectionViewSection: self.selectedSection)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if self.settingsViewType == .language {
            self.searchController?.viewAppears(dataModel: self.dataModel)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.recentContentOffset = self.tableView.contentOffset;
        super.viewWillDisappear(animated)
        
        //Must remove, or this view will scroll because of keyboard actions in upper view.
        let notify = NotificationCenter.default
        notify.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc override func preferredContentSizeChanged(note: NSNotification) {
        super.preferredContentSizeChanged(note: note)

        tableView.reloadData() // updates preferred font size in table
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
        if self.editModeOnOff {
            self.editHandler(sender: nil)
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.tableView.frame = self.view.bounds
        if self.editModeOnOff {
            self.saveHandler(sender: nil)
        }
    }

    @objc func editHandler(sender: UIBarButtonItem?) {
        self.setEditing(true, animated: true)
        self.tableView.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                 action: #selector(saveHandler))
    }
    
    @objc func saveHandler(sender: UIBarButtonItem?) {
        self.setEditing(false, animated: true)
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
    }
}

