//
//  ViewController.swift
//  SafeBible
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
        configuration.userContentController.add(self.messageHandler, name: "callNative")
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle: Bundle = Bundle.main
        print("path \(bundle.bundlePath)")
        let path = bundle.path(forResource: "www/index", ofType: "html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


