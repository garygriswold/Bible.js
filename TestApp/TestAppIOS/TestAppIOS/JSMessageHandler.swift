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
import Utility
import AWS
//import AudioPlayer
import VideoPlayer

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
                let error = logError(plugin: plugin, method: method, message: "Unknown plugin")
                let response = format(handler: handler, result: error)
                controller.jsCallback(response: response)
            }
        } else {
            print("Message set to callNative, must be a dictionary")
            // I think there is no other error response possible here.
        }
    }
    
    private func utilityPlugin(method: String, handler: String, parameters: [Any]) {
        
        if method == "locale" {
            let locale = Locale.current
            let localeStr = locale.identifier
            let language = locale.languageCode
            let script = locale.scriptCode
            let country = locale.regionCode
            print("locale \(localeStr)")
            let result = [localeStr, language, script, country]
            let response = format(handler: handler, result: result) // if error return nil
            controller.jsCallback(response: response)
            
        } else if method == "platform" {
            let platform = "iOS"
            let response = format(handler: handler, result: platform) // if error return nil
            controller.jsCallback(response: response)
            
        //} else if method == "modelType" {
        //    let modelType = UIDevice.current.model
        //    let modelTypeResponse = format(handler: handler, result: modelType) // if error return nil
        //    controller.jsCallback(response: modelTypeResponse)
            
        } else if method == "modelName" {
            let modelName = DeviceSettings.modelName()
            let response = format(handler: handler, result: modelName) // if error return nil
            controller.jsCallback(response: response)
            
        } else if method == "deviceSize" {
            let deviceSize = DeviceSettings.deviceSize()
            let response = format(handler: handler, result: deviceSize) // if error return nil
            controller.jsCallback(response: response)
            
        } else if method == "hideKeyboard" {
            let hidden = self.controller.webview.endEditing(true)
            let response = format(handler: handler, result: hidden) // if error return false
            controller.jsCallback(response: response)
            
        } else {
            logError(plugin: "Utility", method: method, message: "unknown method")
            let response = format(handler: handler) // on error return nil
            controller.jsCallback(response: response)
        }
    }
    
    private func sqlitePlugin(method: String, handler: String, parameters: [Any]) {
        var error: String? = nil
        
        if method == "openDB" {
            if parameters.count == 2 {
                let dbname = parameters[0] as? String ?? "notString"
                let isCopyDatabase = parameters[1] as? Bool ?? true
                do {
                    try Sqlite3.openDB(dbname: dbname, copyIfAbsent: isCopyDatabase)
                } catch let err {
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                }
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "Must have two parameters")
            }
            let response = format(handler: handler, result: error) // if error, return error, else nil
            controller.jsCallback(response: response)
            
        } else if method == "queryJS" {
            var result: [Dictionary<String,Any?>]
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    result = try db.queryV0(sql: statement, values: values)
                } catch let err {
                    result = []
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                }
            } else {
                result = []
                error = logError(plugin: "Sqlite", method: method, message: "must have three parameters")
            }
            let response = format(handler: handler, error: error, result: result) // if error, return error
            controller.jsCallback(response: response)
            
        } else if method == "executeJS" {
            var result: Int = 0
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    result = try db.executeV1(sql: statement, values: values)
                } catch let err {
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                }
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have three parameters")
            }
            let response = format(handler: handler, error: nil, result: result) // if error, return error
            controller.jsCallback(response: response)
            
        } else if method == "bulkExecuteJS" {
            var result: Int = 0
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    result = try db.executeV1(sql: statement, values: values)
                } catch let err {
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                }
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have three parameters")
            }
            let response = format(handler: handler, error: error, result: result) // if error, return error
            controller.jsCallback(response: response)
            
        } else if method == "closeDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                Sqlite3.closeDB(dbname: dbname)
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have one parameter")
            }
            let response = format(handler: handler, result: error) // if error, return error
            controller.jsCallback(response: response)

        } else if method == "listDB" {
            var result: [String]
            do {
                result = try Sqlite3.listDB()
            } catch let err {
                result = []
                logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
            }
            let response = format(handler: handler, result: result) // if error, return []
            controller.jsCallback(response: response)
            
        } else if method == "deleteDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                do {
                    try Sqlite3.deleteDB(dbname: dbname)
                } catch let err {
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                }
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have one parameter")
            }
            let response = format(handler: handler, result: error) // if error, return error, else nil
            controller.jsCallback(response: response)
            
        } else {
            let error = logError(plugin: "Sqlite", method: method, message: "unknown method")
            let response = format(handler: handler, result: error) // if error, return error
            controller.jsCallback(response: response)
        }
    }
    
    private func awsPlugin(method: String, handler: String, parameters: [Any]) {
        var error: String? = nil
        
        if method == "initialize" {
            let s3: AwsS3 = AwsS3Manager.findDbp()
            let result = true
            let response = format(handler: handler, result: result) // if error, return false
            controller.jsCallback(response: response)
            
        } else if method == "downloadZipFile" {
            if parameters.count == 3 {
                let s3Bucket = parameters[0] as? String ?? "notString"
                let s3Key = parameters[1] as? String ?? "notString"
                let filePath = parameters[2] as? String ?? "notString"
                let fileURL = URL(fileURLWithPath: filePath)
                let s3 = AwsS3Manager.findDbp()
                s3.downloadZipFile(s3Bucket: s3Bucket, s3Key: s3Key, filePath: fileURL, view: nil, complete: { err in
                    if err != nil {
                        error = self.logError(plugin: "Sqlite", method: method, message: err!.localizedDescription)
                        // Will this error get captured
                    }
                })
            } else {
                error = logError(plugin: "AWS", method: method, message: "must have three parameters")
            }
            let response = format(handler: handler, result: error) // if error, return error
            controller.jsCallback(response: response)

        } else {
            let error = logError(plugin: "AWS", method: method, message: "unknown method")
            let response = format(handler: handler, result: error) // if error, return error
            controller.jsCallback(response: response)
        }
    }
    
    private func audioPlayerPlugin(method: String, handler: String, parameters: [Any]) {
        var error: String? = nil
        
        if method == "findAudioVersion" {
            if parameters.count == 2 {
                let versionCode = parameters[0] as? String ?? "notString"
                let silCode = parameters[1] as? String ?? "notString"
                // do call here
                let bookList = "abcde"
                let response = format(handler: handler, result: bookList) // if error, return nil, else list
                controller.jsCallback(response: response)
            } else {
                logError(plugin: "AudioPlayer", method: method, message: "must have two parameters")
                let response = format(handler: handler) // if error, return nil
                controller.jsCallback(response: response)
            }

        } else if method == "isPlaying" {
            // do call here
            let isPlaying = "T"
            let response = format(handler: handler, result: isPlaying) // if error, return "F"
            controller.jsCallback(response: response)
            
        } else if method == "present" {
            if parameters.count == 2 {
                let bookCode = parameters[0] as? String ?? "notString"
                let chapter = parameters[1] as? String ?? "notString"
                // do call here
            } else {
                error = logError(plugin: "AudioPlayer", method: method, message: "must have two parameters")
            }
            let response = format(handler: handler, result: error) // if error, return error
            controller.jsCallback(response: response)
        
        } else if method == "stop" {
            // do call here
            let response = format(handler: handler) // if error, return error
            controller.jsCallback(response: response)
            
        } else {
            logError(plugin: "AudioPlayer", method: method, message: "unknown method")
            let response = format(handler: handler) // if error, return nil
            controller.jsCallback(response: response)
        }
 
    }
    
    private func videoPlayerPlugin(method: String, handler: String, parameters: [Any]) {
        var error: String? = nil
        
        if method == "showVideo" {
            if parameters.count == 5 {
                let player = VideoViewPlayer(mediaSource: parameters[0] as? String ?? "notString",
                                             videoId: parameters[1] as? String ?? "notString",
                                             languageId: parameters[2] as? String ?? "notString",
                                             silLang: parameters[3] as? String ?? "notString",
                                             videoUrl: parameters[4] as? String ?? "notString")
                player.begin(complete: { err in
                    if err != nil {
                        error = self.logError(plugin: "VideoPlayer", method: method, message: err!.localizedDescription)
                        // Will this error get captured?
                    }
                })
            } else {
                error = logError(plugin: "VideoPlayer", method: method, message: "must have five parameters")
            }
            let response = format(handler: handler, result: error) // if error, return error
            controller.jsCallback(response: response)
            
        } else {
            let error = logError(plugin: "VideoPlayer", method: method, message: "unknown method")
            let response = format(handler: handler, result: error) // if error, return error
            controller.jsCallback(response: response)
        }
    }
    private func format(handler: String) -> String {
        return handler + "();"
    }
    private func format(handler: String, result: String?) -> String {
        if let res = result {
            return handler + "('" + res + "');"
        } else {
            return handler + "();"
        }
    }
    private func format(handler: String, result: Bool) -> String {
        return handler + "(" + String(result) + ");"
    }
    private func format(handler: String, error: String?, result: Int) -> String {
        return handler + "(" + String(result) + ");"
    }
    private func format(handler: String, result: [String?]) -> String {
        do {
            let message = try JSONSerialization.data(withJSONObject: result)
            return format(handler: handler, result: String(data: message, encoding: String.Encoding.utf8)!)
        } catch let jsonError {
            let error = logError(plugin: "Utility", method: "locale", message: jsonError.localizedDescription)
            return format(handler: handler, result: error)
        }
    }
    private func format(handler: String, error: String?, result: [Dictionary<String, Any?>]) -> String {
        do {
            let message = try JSONSerialization.data(withJSONObject: result)
                                                 //options: JSONSerialization.WritingOptions.prettyPrinted)
            return format(handler: handler, result: String(data: message, encoding: String.Encoding.utf8)!)
        } catch let jsonError {
            let error = logError(plugin: "Sqlite", method: "queryJS", message: jsonError.localizedDescription)
            return format(handler: handler, result: error)
        }
    }
    private func logError(plugin: String, method: String, message: String) -> String {
        let error = "PLUGIN ERROR: \(plugin).\(method):  \(message)"
        print(error)
        return error
    }
}
