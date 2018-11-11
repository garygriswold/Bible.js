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
    private var _reference: Reference!
    var reference: Reference! {
        get { return _reference }
    }

    deinit {
        print("****** deinit Reader View Controller \(self._reference.toString())")
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
    }
    
    func loadReference(reference: Reference) {
        self._reference = reference
        self.view.backgroundColor = AppFont.backgroundColor // to ensure loadView has been called
        let biblePage = BiblePageModel()
        biblePage.loadPage(reference: _reference, webView: self.webView)
    }
    
    func clearWebView() {
        if self.webView != nil {
            // measures about 0.35 to 0.7 ms on simulator
            self.webView.loadHTMLString(DynamicCSS.shared.getEmptyHtml(), baseURL: nil)
        }
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
