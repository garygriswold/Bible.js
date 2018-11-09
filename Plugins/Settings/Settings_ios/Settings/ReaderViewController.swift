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

class ReaderViewController : AppViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    var reference: Reference!
    var which: GetChapter = .this
    
    deinit {
        print("****** deinit Reader View Controller \(self.reference)")
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.frame = UIScreen.main.bounds
        self.view.backgroundColor = AppFont.backgroundColor

        self.navigationItem.title = NSLocalizedString("Read", comment: "Read view page title")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        self.webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        self.webView.backgroundColor = AppFont.backgroundColor
        
        self.webView.scrollView.frame = UIScreen.main.bounds
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.backgroundColor = AppFont.backgroundColor
        
        self.view.addSubview(self.webView)
        
        self.webView.navigationDelegate = self

        let biblePage = BiblePageModel()
        self.reference = biblePage.loadPage(reference: self.reference, which: self.which,
                                            webView: self.webView)
        self.which = .this
        
        print("Loading Page \(self.reference!)")
    }
    
    @objc override func preferredContentSizeChanged(note: NSNotification) {
        super.preferredContentSizeChanged(note: note)

        let message = DynamicCSS.shared.fontSize.genRule()
        self.execJavascript(message: message)
    }

    
    func execJavascript(message: String) {
        self.webView.evaluateJavaScript(message, completionHandler: { data, error in
            if let err = error {
                print("jsCallbackError \(err)")
            }
            if let resp = data {
                print("jsCallback has a response \(resp)")
            }
        })
    }
}
