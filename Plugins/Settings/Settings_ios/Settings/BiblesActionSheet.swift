//
//  BiblesActionSheet.swift
//  Settings
//
//  Created by Gary Griswold on 10/19/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class BiblesActionSheet : UIAlertController {
    
    private weak var controller: ReaderPagesController?
    
    init(controller: ReaderPagesController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
            let biblesController = SettingsViewController(settingsViewType: .bible)
            if let nav = self.controller?.navigationController {
                nav.pushViewController(biblesController, animated: true)
            }
        })
        self.addAction(moreBibles)
        
        let moreLangText = NSLocalizedString("+ More Languages", comment: "Title on action sheet")
        let moreLang = UIAlertAction(title: moreLangText, style: .default, handler: { _ in
            let langController = SettingsViewController(settingsViewType: .language)
            if let nav = self.controller?.navigationController {
                nav.pushViewController(langController, animated: true)
            }
        })
        self.addAction(moreLang)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.addAction(cancel)
    }
}
