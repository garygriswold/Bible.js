//
//  BibleDetailViewController.swift
//  Settings
//
//  Created by Gary Griswold on 8/3/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

class BibleDetailViewController : UIViewController {
    
    private weak var controller: SettingsViewController?
    private let indexPath: IndexPath
    private let bible: Bible
    private var textView: UITextView
    
    init(controller: SettingsViewController, indexPath: IndexPath, bible: Bible) {
        self.controller = controller
        self.indexPath = indexPath
        self.bible = bible
        self.textView = UITextView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.indexPath = IndexPath(item: 0, section: 0)
        self.bible = Bible(bibleId: "", abbr: "", iso3: "", name: "", locale: Locale(identifier: "en-US"))
        self.textView = UITextView(frame: .zero)
        super.init(coder: coder)
    }
    
    deinit {
        print("**** deinit BibleDetailViewController ******")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // set Top Bar items
        self.navigationItem.title = bible.name
        if indexPath.section > 0 { // is an available Bible
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                     target: self,
                                                                     action: #selector(addHandler))
        }
        self.textView = UITextView(frame: UIScreen.main.bounds)
        let inset = self.textView.frame.width * 0.05
        self.textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.textView.text = debugInfo()
        self.textView.isEditable = false
        self.textView.isSelectable = true
        //self.textView.allowsEditingTextAttributes = true
        self.textView.font = AppFont.serif(style: .body)
        self.view.addSubview(self.textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.font = AppFont.sansSerif(style: .body)
    }
    
    private func debugInfo() -> String {
        var lines = [String]()
        let what = "Huh?"
        lines.append("bibleId = \(self.bible.bibleId)")
        lines.append("abbr = \(self.bible.abbr)")
        lines.append("name = \(self.bible.name)")
        lines.append("iso3 = \(self.bible.iso3)")
        let english = Locale.current.localizedString(forLanguageCode: self.bible.iso3)
        lines.append("english = \(english ?? what)")
        let localized = Locale(identifier: self.bible.iso3).localizedString(forLanguageCode: self.bible.iso3)
        lines.append("localized = \(localized ?? what)")
        return lines.joined(separator: "\n")
    }
    
    @objc func addHandler(sender: UIBarButtonItem?) {
        if let tableView = self.controller?.tableView {
            self.controller?.dataSource.insertRow(tableView: tableView, indexPath: self.indexPath)
        }
        self.controller?.navigationController?.popViewController(animated: true)
    }
}
