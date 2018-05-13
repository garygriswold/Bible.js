//
//  JSMessageHandler.swift
//  TestAppIOS
//
//  Created by Gary Griswold on 5/10/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit
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
            let method = request["method"] as? String ?? "notString"
            let handler = request["handler"] as? String ?? "notString"
            let parameters = request["parameters"] as? [Any] ?? []
            if (plugin == "Utility") {
                utilityPlugin(method: method, handler: handler, parameters: parameters)
            } else if plugin == "Sqlite" {
                sqlitePlugin(method: method, handler: handler, parameters: parameters)
            } else if plugin == "AWS" {
                awsPlugin(method: method, handler: handler, parameters: parameters)
            } else if plugin == "AudioPlayer" {
                audioPlayerPlugin(method: method, handler: handler, parameters: parameters)
            } else if plugin == "VideoPlayer" {
                videoPlayerPlugin(method: method, handler: handler, parameters: parameters)
            } else {
                print("Unknown plugin \(plugin).\(method)")
                // Should I try to respond to this?
            }
        } else {
            print("Message set to callNative, must be a dictionary")
            // I think there is no other error response possible here.
        }
    }
    
    private func utilityPlugin(method: String, handler: String, parameters: [Any]) {
        
        if method == "locale" {
            let locale = Locale.current.identifier
            print("locale \(locale)")
            let response = format(handler: handler, result: locale)
            controller.jsCallback(response: response)
            
        } else if method == "platform" {
            let platform = "iOS"
            let response = format(handler: handler, result: platform)
            controller.jsCallback(response: response)
            
        //} else if method == "modelType" {
        //    let modelType = UIDevice.current.model
        //    let modelTypeResponse = format(handler: handler, result: modelType)
        //    controller.jsCallback(response: modelTypeResponse)
            
        } else if method == "modelName" {
            //let modelName = DeviceSettings.modelName()
            let modelName = "Dummy"
            let response = format(handler: handler, result: modelName)
            controller.jsCallback(response: response)
            
        //} else if method == "deviceSize" {
        //    //let deviceSize = DeviceSettings.deviceSize()
        //    let deviceSize = "Dummy"
        //    let deviceSizeResponse = format(handler: handler, result: deviceSize)
        //    controller.jsCallback(response: deviceSizeResponse)
            
        } else if method == "hideKeyboard" {
            //let hidden = self.webView.endEditing(true)
            let hidden = true
            let response = format(handler: handler, result: hidden)
            controller.jsCallback(response: response)
            
        } else {
            print("Unknown method \(method) in Plugin Utility")
        }
    }
    
    private func sqlitePlugin(method: String, handler: String, parameters: [Any]) {
        
        if method == "openDB" {
            if parameters.count == 2 {
                let dbname = parameters[0] as? String ?? "notString"
                let isCopyDatabase = parameters[1] as? Bool ?? true
                // do call here
                let error = "whatever"
                let response = format(handler: handler, result: error)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, result: "openDB must have two parameters")
                controller.jsCallback(response: response)
            }
            
        } else if method == "queryJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                // do call here
                let result = [Dictionary<String,Any?>]()
                let response = format(handler: handler, error: nil, result: result)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, error: "queryJS must have three parameters", result: [])
                controller.jsCallback(response: response)
            }
            
        } else if method == "executeJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                // do call here
                let result = 1
                let response = format(handler: handler, error: nil, result: result)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, error: "executeJS must have three parameters", result: [])
                controller.jsCallback(response: response)
            }
            
        } else if method == "bulkExecuteJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                // do call here
                let result = 1
                let response = format(handler: handler, error: nil, result: result)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, error: "bulkExecuteJS must have three parameters", result: [])
                controller.jsCallback(response: response)
            }
            
        } else if method == "closeDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                // do call here
                let error = "whatever"
                let response = format(handler: handler, result: error)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, result: "closeDB must have one parameter")
                controller.jsCallback(response: response)
            }

        } else if method == "listDB" {
            // do call here
            let result = "abcde"
            let response = format(handler: handler, result: result)
            controller.jsCallback(response: response)
            
        } else if method == "deleteDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                // do call here
                let error = "whatever"
                let response = format(handler: handler, result: error)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, result: "deleteDB must have one parameter")
                controller.jsCallback(response: response)
            }
            
        } else {
            print("Unknown method \(method) in Plugin Sqlite")
        }
    }
    
    private func awsPlugin(method: String, handler: String, parameters: [Any]) {
        
        if method == "initialize" {
            // do call here
            let result = true
            let response = format(handler: handler, result: result)
            controller.jsCallback(response: response)
            
        } else if method == "downloadZipFile" {
            if parameters.count == 3 {
                let s3Bucket = parameters[0] as? String ?? "notString"
                let s3Key = parameters[1] as? String ?? "notString"
                let filePath = parameters[2] as? String ?? "notString"
                // do call here
                let error = "whatever"
                let response = format(handler: handler, result: error)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, result: "downloadZipFile must have three parameters")
                controller.jsCallback(response: response)
            }

        } else {
            print("Unknown method \(method) in Plugin AWS")
        }
    }
    
    private func audioPlayerPlugin(method: String, handler: String, parameters: [Any]) {
        
        if method == "findAudioVersion" {
            if parameters.count == 2 {
                let versionCode = parameters[0] as? String ?? "notString"
                let silCode = parameters[1] as? String ?? "notString"
                // do call here
                let bookList = "abcde"
                let response = format(handler: handler, result: bookList)
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, result: "findAudioVersion must have two parameters")
                controller.jsCallback(response: response)
            }

        } else if method == "isPlaying" {
            // do call here
            let isPlaying = true
            let response = format(handler: handler, result: isPlaying)
            controller.jsCallback(response: response)
            
        } else if method == "present" {
            if parameters.count == 2 {
                let bookCode = parameters[0] as? String ?? "notString"
                let chapter = parameters[1] as? String ?? "notString"
                // do call here
                let response = handler + "();"
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, result: "present must have two parameters")
                controller.jsCallback(response: response)
            }
        
        } else if method == "stop" {
            // do call here
            let response = handler + "();"
            controller.jsCallback(response: response)
            
        } else {
            print("Unknown method \(method) in Plugin AudioPlayer")
        }
 
    }
    
    private func videoPlayerPlugin(method: String, handler: String, parameters: [Any]) {
        
        if method == "showVideo" {
            if parameters.count == 5 {
                let mediaSource = parameters[0] as? String ?? "notString"
                let videoId = parameters[1] as? String ?? "notString"
                let languageId = parameters[2] as? String ?? "notString"
                let silCode = parameters[3] as? String ?? "notString"
                let videoUrl = parameters[4] as? String ?? "notString"
                // do call here
                let response = handler + "();"
                controller.jsCallback(response: response)
            } else {
                let response = format(handler: handler, result: "showVideo must have five parameters")
                controller.jsCallback(response: response)
            }
        } else {
            print("Unknown method \(method) in Plugin VideoPlayer")
        }
    }
    
    private func format(handler: String, result: String) -> String {
        return handler + "('" + result + "');"
    }
    private func format(handler: String, result: Bool) -> String {
        return handler + "(" + String(result) + ");"
    }
    private func format(handler: String, error: String?, result: Int) -> String {
        return handler + "(" + String(result) + ");"
    }
    private func format(handler: String, error: String?, result: [Dictionary<String, Any>]) -> String {
        do {
            let message = try JSONSerialization.data(withJSONObject: result)
                                                 //options: JSONSerialization.WritingOptions.prettyPrinted)
            return handler + "('" + String(data: message, encoding: String.Encoding.utf8)! + "');"
        } catch let jsonError {
            print("ERROR while converting message to JSON \(jsonError)")
            return handler + "('" + jsonError.localizedDescription + "');"
        }
    }
}
