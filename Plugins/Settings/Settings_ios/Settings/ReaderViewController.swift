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
    
    deinit {
        print("****** deinit Reader View Controller \(self.reference)")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Read", comment: "Read view page title")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        self.webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        self.webView.backgroundColor = AppFont.backgroundColor
        self.view = self.webView
        
        self.webView.navigationDelegate = self

        let biblePage = BiblePageModel(reference: self.reference)
        biblePage.loadPage(webView: self.webView)
        
        print("Loading Page \(self.reference!)")
    }
    
    @objc override func preferredContentSizeChanged(note: NSNotification) {
        super.preferredContentSizeChanged(note: note)

        self.updateFontSize()
    }
    
    private func updateFontSize() {
        let font = AppFont.serif(style: .body)
        let verseNumbers = AppFont.verseNumbers ? "inline" : "none"
        let nightMode = AppFont.nightMode ? "background-color:black; color:white;"
        : "background-color:white; color:black;"
        let message = "var sheet = document.styleSheets[0];\n"
            + "sheet.addRule('html', 'font-size:\(Int(font.pointSize))pt');\n"
            + "sheet.addRule('.section,.chapter', 'line-height:\(AppFont.bodyLineHeight);');\n"
            + "sheet.addRule('.v-num', 'display:\(verseNumbers)');\n"
            + "sheet.addRule('html', '\(nightMode)');"
        print(message)
        self.execJavascript(message: message)
    }
    
    private func execJavascript(message: String) {
        self.webView.evaluateJavaScript(message, completionHandler: { data, error in
            if let err = error {
                print("jsCallbackError \(err)")
            }
            if let resp = data {
                print("jsCallback has a response \(resp)")
            }
        })
    }
    
    //
    // WKNavigationDelegate
    //
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.updateFontSize()
    }
}
