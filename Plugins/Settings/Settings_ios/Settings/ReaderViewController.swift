//
//  TestController.swift
//  Settings
//
//  Created by Gary Griswold on 10/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ReaderViewController : UIViewController {
    
    private var webView: WKWebView!
    // Toolbar
    private var versionLabel: UILabel!
    private var tocBookLabel: UILabel!
    private var tocChapLabel: UILabel!
    
    deinit {
        print("****** deinit Reader View Controller")
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Read", comment: "Read view page title")
        
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.backgroundColor = .white
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ref = HistoryModel.shared.current()
        self.loadBiblePage(reference: ref)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.isToolbarHidden = true
    }
    
    func loadBiblePage(reference: Reference) {
        self.tocBookLabel.text = reference.bookId
        self.tocChapLabel.text = String(reference.chapter)
        self.versionLabel.text = reference.abbr
        
        let bundle: Bundle = Bundle.main
        let path = bundle.path(forResource: "www/index", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    private func createToolbar() {
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
        self.setToolbarItems(items, animated: true)
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
        print("toc book handler")
        /*
        //let bible = Bible(bibleId: "ENGKJV", abbr: "KJV", iso3: "eng", name: "King James",
        //                 locale: Locale(identifier: "en"))
        let bible = Bible(bibleId: "ENGWEB", abbr: "WEB", iso3: "eng", name: "World English",
                          locale: Locale(identifier: "en"))
        //let bible = Bible(bibleId: "ENGESV", abbr: "ESV", iso3: "eng", name: "English Standard",
        //                  locale: Locale(identifier: "en"))
        let toc = TableContentsModel(bible: bible)
        toc.load()
        */
        let tableContents = TableContentsViewController()
        self.navigationController?.pushViewController(tableContents, animated: true)
    }
    
    @objc func tocChapHandler(sender: UIBarButtonItem) {
        print("toc chapter handler")
    }
    
    @objc func versionTapHandler(sender: UIBarButtonItem) {
        let biblesAlert = BiblesActionSheet(controller: self)
        self.present(biblesAlert, animated: true, completion: nil)
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
