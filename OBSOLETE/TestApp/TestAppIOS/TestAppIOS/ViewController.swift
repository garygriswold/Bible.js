//
//  ViewController.swift
//  TestAppIOS
//
//  Created by Gary Griswold on 5/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// https://developer.apple.com/documentation/webkit/wkwebview
// script injection example
// https://gist.github.com/morhekil/d1ff977e40b63cdd6379a8dac81e506c
// call with return example
// http://igomobile.de/2017/03/06/wkwebview-return-a-value-from-native-code-to-javascript/
//
import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {

    private var webView: WKWebView!
    private var messageHandler: JSMessageHandler!
    private var navigationDelegate: NavigationDelegate!
    
    var webview: WKWebView {
        get {
            return webView
        }
    }
    
    override func loadView() {
        self.messageHandler = JSMessageHandler(controller: self)
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true;
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true; // not sure
        setScript1(configuration: configuration)
        configuration.userContentController.add(self.messageHandler, name: "callNative")
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.uiDelegate = self
        self.navigationDelegate = NavigationDelegate()
        self.webView.navigationDelegate = self.navigationDelegate
        view = webView
    }
    
    private func setScript1(configuration: WKWebViewConfiguration) {
        let startTime: Date = Date()
        let bundle = Bundle.main
        let scriptPath: String? = bundle.path(forResource: "FullBibleApp", ofType: "js")
        let scriptURL: URL = URL(fileURLWithPath: scriptPath!)
        do {
            let scriptStr: String = try String(contentsOf: scriptURL, encoding: .utf8)
            let script = WKUserScript(source: scriptStr, injectionTime: WKUserScriptInjectionTime.atDocumentStart,
                                      forMainFrameOnly: true)
            configuration.userContentController.addUserScript(script)
            print("**** duration \(Date().timeIntervalSince(startTime))")
            print("stop here")
        } catch let err {
            print("\(err)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle.main
        print("path \(bundle.bundlePath)")
        
        let path = bundle.path(forResource: "index", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        webView.load(request)
        
        //let index = URL(fileURLWithPath: "/SafeBible/www/index.html", isDirectory: false)
        //let www = URL(fileURLWithPath: "/SafeBible/www", isDirectory: true)
        //self.webView.loadFileURL(url, allowingReadAccessTo: www)
    }
    
    private func startJS() {
        let message = "var ele = document.getElementById('locale'); ele.innerHTML = 'Bob';"
        //let message = "testAWS();"
        //let message = "var initializer = new AppInitializer();\ninitializer.begin();"
        print("START JS: \(message)")
        self.webView.evaluateJavaScript(message, completionHandler: { data, error in
            if let err = error {
                print("jsStartError \(err)")
            }
            if let resp = data {
                print("jsStart has unexpected response \(resp)")
            }
        })
    }
    
    /** WKUIDelegate: Notifies app that the DOM window closed successfully */
    func webViewDidClose(_ view: WKWebView) {
        print("**** Did receive WKUIDelegate webViewDidClose ****")
    }
}

