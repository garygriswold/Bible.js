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

    var webView: WKWebView!
    var messageHandler: JSMessageHandler!
    
    override func loadView() {
        self.messageHandler = JSMessageHandler(controller: self)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self.messageHandler, name: "callNative")
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle.main
        print("path \(bundle.bundlePath)")
        let path = bundle.path(forResource: "index", ofType: ".html")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func jsCallback(response: String) {
        self.webView.evaluateJavaScript(response, completionHandler: { data, error in
            if let err = error {
                print("jsCallbackError \(err)")
            }
            if let resp = data {
                print("jsCallback has unexpected response \(resp)")
            }
        })
    }
}

