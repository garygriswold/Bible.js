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
    var reference: Reference!
    
    deinit {
        print("****** deinit Reader View Controller")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Read", comment: "Read view page title")
        
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.backgroundColor = .white
        self.view = self.webView

        let biblePage = BiblePage(reference: self.reference)
        biblePage.loadPage(webView: self.webView)
        
        print("Loading Page \(self.reference)")
    }
}
