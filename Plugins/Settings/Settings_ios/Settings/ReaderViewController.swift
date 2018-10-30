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

class ReaderViewController : AppViewController {
    
    private var webView: WKWebView!
    
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
        let biblePage = HistoryModel.shared.biblePage
        biblePage.loadPage(webView: self.webView)
    }
}
