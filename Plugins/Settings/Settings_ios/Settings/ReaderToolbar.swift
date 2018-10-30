//
//  ReaderToolbar.swift
//  Settings
//
//  Created by Gary Griswold on 10/30/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class ReaderToolbar {
    
    private weak var controller: ReaderPagesController?
    private weak var navigationController: UINavigationController?
    
    private var versionLabel: UILabel!
    private var tocBookLabel: UILabel!
    private var tocChapLabel: UILabel!
    
    init(controller: ReaderPagesController) {
        self.controller = controller
        self.navigationController = controller.navigationController
        
        if let nav = self.navigationController {
            
            nav.toolbar.isTranslucent = false
            nav.toolbar.barTintColor = .white
        }
        var items = [UIBarButtonItem]()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let menuImage = UIImage(named: "www/images/ui-menu.png")
        let menu = UIBarButtonItem(image: menuImage, style: .plain, target: self,
                                   action: #selector(menuTapHandler))
        items.append(menu)
        items.append(spacer)
        
        let priorImage = UIImage(named: "www/images/ios-previous.png")
        let prior = UIBarButtonItem(image: priorImage, style: .plain, target: self,
                                    action: #selector(priorTapHandler))
        items.append(prior)
        //items.append(spacer)
        
        let nextImage = UIImage(named: "www/images/ios-next.png")
        let next = UIBarButtonItem(image: nextImage, style: .plain, target: self,
                                   action: #selector(nextTapHandler))
        items.append(next)
        items.append(spacer)
        
        self.tocBookLabel = toolbarLabel(width: 80, action: #selector(tocBookHandler))
        let tocBook = UIBarButtonItem(customView: self.tocBookLabel)
        items.append(tocBook)
        items.append(spacer)
        
        self.tocChapLabel = toolbarLabel(width: 22, action: #selector(tocChapHandler))
        let tocChap = UIBarButtonItem(customView: self.tocChapLabel)
        items.append(tocChap)
        items.append(spacer)
        
        self.versionLabel = toolbarLabel(width: 38, action: #selector(versionTapHandler))
        let version = UIBarButtonItem(customView: self.versionLabel)
        items.append(version)
        items.append(spacer)
        
        let audioImage = UIImage(named: "www/images/mus-vol-med.png")
        let audio = UIBarButtonItem(image: audioImage, style: .plain, target: self,
                                    action: #selector(audioTapHandler))
        items.append(audio)
        items.append(spacer)
        
        let composeImage = UIImage(named: "www/images/ios-new.png")
        let compose = UIBarButtonItem(image: composeImage, style: .plain, target: self,
                                      action: #selector(composeTapHandler))
        items.append(compose)
        items.append(spacer)
        
        let searchImage = UIImage(named: "www/images/ios-search.png")
        let search = UIBarButtonItem(image: searchImage, style: .plain, target: self,
                                     action: #selector(searchTapHandler))
        items.append(search)
        self.controller!.setToolbarItems(items, animated: true)
    }
    
    func loadBiblePage(reference: Reference) {
        
        self.tocBookLabel.frame = CGRect(x: 0, y: 0, width: 80, height: 32) // prevents fields running together
        self.tocBookLabel.text = reference.bookName
        self.tocChapLabel.text = String(reference.chapter)
        self.versionLabel.text = reference.abbr
        
    }
    
    @objc func menuTapHandler(sender: UIBarButtonItem) {
        let menuController = SettingsViewController(settingsViewType: .primary)
        self.navigationController?.pushViewController(menuController, animated: true)
    }
    
    @objc func priorTapHandler(sender: UIBarButtonItem) {
        print("prior button handler")
    }
    
    @objc func nextTapHandler(sender: UIBarButtonItem) {
        print("next button handler")
    }
    
    @objc func tocBookHandler(sender: UIBarButtonItem) {
        let tableContents = TOCBooksViewController()
        self.navigationController?.pushViewController(tableContents, animated: true)
    }
    
    @objc func tocChapHandler(sender: UIBarButtonItem) {
        if let book = HistoryModel.shared.currBook {
            let chaptersTOC = TOCChaptersViewController(book: book)
            self.navigationController?.pushViewController(chaptersTOC, animated: true)
        }
    }
    
    @objc func versionTapHandler(sender: UIBarButtonItem) {
        let biblesAlert = BiblesActionSheet(controller: self.controller!)
        self.controller!.present(biblesAlert, animated: true, completion: nil)
    }
    
    @objc func audioTapHandler(sender: UIBarButtonItem) {
        print("audio button handler")
    }
    
    @objc func composeTapHandler(sender: UIBarButtonItem) {
        print("compose button handler")
    }
    
    @objc func searchTapHandler(sender: UIBarButtonItem) {
        print("search button handler")
    }
    
    private func toolbarLabel(width: CGFloat, action: Selector) -> UILabel {
        let frame = CGRect(x: 0, y: 0, width: width, height: 32)
        let label = UILabel(frame: frame)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        label.textColor = UIColor(red: 0.24, green: 0.5, blue: 0.96, alpha: 1.0)
        let gesture = UITapGestureRecognizer(target: self, action: action)
        gesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(gesture)
        label.isUserInteractionEnabled = true
        return label
    }
}
