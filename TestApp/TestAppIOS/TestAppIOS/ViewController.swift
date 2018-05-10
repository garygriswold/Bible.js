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

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {

    var webView: WKWebView!
    
    override func loadView() {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "callNative")
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
    
    /**
     * var aMessage = {'command':'hello', data:[5,6,7,8,9]}
     * window.webkit.messageHandlers.callNative.postMessage(aMessage)
    */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("got message: \(message.body)")
        if message.body is Dictionary<String, Any> {
            let request = (message.body as? Dictionary<String, Any>)!
            let plugin = request["plugin"] as? String ?? "notString"
            if (plugin == "Utility") {
                utilityPlugin(request: request)
            } else {
                print("Unknown plugin \(plugin)")
                // Should I try to respond to this?
            }
        } else {
            print("Message set to callNative, must be a dictionary")
            // I think there is no other error response possible here.
        }
    }
    
    private func utilityPlugin(request: Dictionary<String, Any>) {
        print("request \(request)")
        let method = request["method"] as? String ?? "notString"
        let handler = request["handler"] as? String ?? "notString"
        print("method \(method)")
        if (method == "getLocale") {
            var locale = Locale.current.identifier
            locale = "es_GB"
            print("locale \(locale)")
            let response = handler + "('" + locale + "');";
            callback(response: response)
        } else {
            print("Unknown method \(method) in Plugin Utility")
        }
    }
    
    private func callback(response: String) {
        self.webView.evaluateJavaScript(response, completionHandler: { data, error in
            print("evaluate error \(error)  \(data)")
        })
    }
}

