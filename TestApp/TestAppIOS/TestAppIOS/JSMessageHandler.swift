//
//  JSMessageHandler.swift
//  TestAppIOS
//
//  Created by Gary Griswold on 5/10/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import WebKit

class JSMessageHandler : NSObject, WKScriptMessageHandler {
    
    let controller: ViewController

    init(controller: ViewController) {
        self.controller = controller
        super.init()
    }
    deinit {
        print("****** Deinitialize JSMessageHandler ******")
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
            locale = "es_XB"
            print("locale \(locale)")
            let response = handler + "('" + locale + "');";
            controller.jsCallback(response: response)
        } else {
            print("Unknown method \(method) in Plugin Utility")
        }
    }
}
