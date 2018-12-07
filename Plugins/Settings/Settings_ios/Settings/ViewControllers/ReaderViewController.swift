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

        self.navigationItem.title = NSLocalizedString("Read", comment: "Read view page title")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        let js = Note.decodeRange + Note.installEffect + Note.encodeRange
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.webView.backgroundColor = AppFont.backgroundColor
        
        self.webView.scrollView.frame = self.view.bounds
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.backgroundColor = AppFont.backgroundColor
        
        self.view.addSubview(self.webView)
        
        self.webView.navigationDelegate = self
        
        self.webView.createEditMenu() // Found in extension WKWebView
    }
    
    func loadReference(reference: Reference) {
        self._reference = reference
        self.loadViewIfNeeded()
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
    
    //
    // Delegate
    //
    func webView(_: WKWebView, didFinish: WKNavigation!) {
        print("Web page loaded \(_reference.toString())")
        self.webView.addNotes(reference: _reference)
        NotificationCenter.default.post(name: ReaderPagesController.WEB_LOAD_DONE, object: nil)
    }
    
    func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) {
        print("ERROR: Bible page load error \(withError)")
        NotificationCenter.default.post(name: ReaderPagesController.WEB_LOAD_DONE, object: nil)
    }
}
