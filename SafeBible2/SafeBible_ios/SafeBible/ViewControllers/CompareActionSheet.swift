//
//  CompareActionSheet.swift
//  SafeBible
//
//  Created by Gary Griswold on 2/19/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class CompareActionSheet : UIAlertController {
    
    static func present(controller: CompareViewController, bibleModel: BibleModel) {
        let biblesAlert = CompareActionSheet(controller: controller, bibleModel: bibleModel)
        controller.present(biblesAlert, animated: true, completion: nil)
    }
    
    private weak var controller: CompareViewController?
    private var bibleModel: BibleModel
    
    init(controller: CompareViewController, bibleModel: BibleModel) {
        self.controller = controller
        self.bibleModel = bibleModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("CompareActionSheet(coder:) is not implemented.")
    }
    
    override var preferredStyle: UIAlertController.Style { get { return .actionSheet } }
    
    override func loadView() {
        super.loadView()
        
        for section in 0..<self.bibleModel.available.count {
            var lang = self.bibleModel.available[section]
            for row in 0..<lang.count {
                let bible = lang[row]
                let item = UIAlertAction(title: bible.name, style: .default, handler: { _ in
                    let availIndex = IndexPath(row: row, section: section)
                    let selectIndex = IndexPath(row: self.bibleModel.selected.count, section: 0)
                    self.bibleModel.moveAvailableToSelected(source: availIndex, destination: selectIndex,
                                                            inSearch: false)
                    self.controller?.tableView.reloadData()
                })
                self.addAction(item)
            }
        }
        
        let moreLangText = NSLocalizedString("+ More Languages", comment: "Title on action sheet")
        let moreLang = UIAlertAction(title: moreLangText, style: .default, handler: { _ in
            SettingsViewController.push(settingsViewType: .language, controller: self.controller,
                                        language: nil)
        })
        self.addAction(moreLang)
        
        let cancelStr = NSLocalizedString("Cancel", comment: "Cancel button on Action Sheet")
        let cancel = UIAlertAction(title: cancelStr, style: .cancel, handler: nil)
        self.addAction(cancel)
    }
}

