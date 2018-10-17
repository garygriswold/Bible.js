//
//  TestController.swift
//  Settings
//
//  Created by Gary Griswold on 10/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import WebKit

class ReaderViewController : UIViewController {
    
    private var webView: WKWebView!
    
    deinit {
        print("****** deinit Reader View Controller")
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func loadView() {
        super.loadView()
        
        if let nav = self.navigationController {
            nav.setNavigationBarHidden(true, animated: false)
        }
        
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.backgroundColor = .white
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle: Bundle = Bundle.main
        let path = bundle.path(forResource: "www/index", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        self.webView.load(request)
        
        self.createToolbar()
    }
    
    private func createToolbar() {
        if let nav = self.navigationController {
            nav.isToolbarHidden = false
            
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
        
        let tocImage = UIImage(named: "www/images/ios-keypad.png")
        let toc = UIBarButtonItem(image: tocImage, style: .plain, target: self,
                                   action: #selector(tocTapHandler))
        items.append(toc)
        items.append(spacer)
        
        let versionImage = UIImage(named: "www/images/cel-bible.png")
        let version = UIBarButtonItem(image: versionImage, style: .plain, target: self,
                                      action: #selector(versionTapHandler))
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
        print("menu button handler")
    }
    
    @objc func priorTapHandler(sender: UIBarButtonItem) {
        print("prior button handler")
    }
    
    @objc func nextTapHandler(sender: UIBarButtonItem) {
        print("next button handler")
    }
    
    @objc func tocTapHandler(sender: UIBarButtonItem) {
        print("toc button handler")
    }
    
    @objc func versionTapHandler(sender: UIBarButtonItem) {
        print("version button handler")
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
}
