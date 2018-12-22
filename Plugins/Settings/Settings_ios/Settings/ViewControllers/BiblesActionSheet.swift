//
//  BiblesActionSheet.swift
//  Settings
//
//  Created by Gary Griswold on 10/19/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class BiblesActionSheet : UIAlertController {
    
    static func present(controller: UIViewController?) {
        if let ctrl = controller {
            let biblesAlert = BiblesActionSheet(controller: ctrl)
            ctrl.present(biblesAlert, animated: true, completion: nil)
        }
    }
    
    private weak var controller: UIViewController?
    
    init(controller: UIViewController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("BiblesActionSheet(coder:) is not implemented.")
    }
    
    override var preferredStyle: UIAlertController.Style { get { return .actionSheet } }
    
    override func loadView() {
        super.loadView()
        
        let dataModel = BibleModel(availableSection: 0, language: nil, selectedOnly: true)
        
        for index in 0..<dataModel.selectedCount {
            if let bible = dataModel.getSelectedBible(row: index) {
                let item = UIAlertAction(title: bible.name, style: .default, handler: { _ in
                    HistoryModel.shared.changeBible(bible: bible)
                    NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                                    object: HistoryModel.shared.current())
                })
                self.addAction(item)
            }
        }
        
        let moreBiblesText = NSLocalizedString("+ More Bibles", comment: "Title on action sheet")
        let moreBibles = UIAlertAction(title: moreBiblesText, style: .default, handler: { _ in
            SettingsViewController.push(settingsViewType: .bible, controller: self.controller, language: nil)
        })
        self.addAction(moreBibles)
        
        let moreLangText = NSLocalizedString("+ More Languages", comment: "Title on action sheet")
        let moreLang = UIAlertAction(title: moreLangText, style: .default, handler: { _ in
            SettingsViewController.push(settingsViewType: .language, controller: self.controller,
                                        language: nil)
        })
        self.addAction(moreLang)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.addAction(cancel)
    }
}
