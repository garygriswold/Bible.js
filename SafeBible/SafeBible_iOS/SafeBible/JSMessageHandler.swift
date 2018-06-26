//
//  JSMessageHandler.swift
//  SafeBible
//
//  Created by Gary Griswold on 5/10/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
//

import Foundation
import UIKit
import WebKit
import Utility
import AWS
import AudioPlayer
import VideoPlayer

public class JSMessageHandler : NSObject, WKScriptMessageHandler {
    
    let controller: ViewController
    private var videoViewPlayer: VideoViewPlayer?
    
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
    public func userContentController(_ userContentController: WKUserContentController, didReceive: WKScriptMessage) {

        if didReceive.body is Dictionary<String, Any> {
            print("CALL FROM JS: \(didReceive.body)")
            let request = (didReceive.body as? Dictionary<String, Any>)!
            let callbackId = request["callbackId"] as? String ?? "notString"
            let plugin = request["plugin"] as? String ?? "notString"
            let method = request["method"] as? String ?? "notString"
            let parameters = request["parameters"] as? [Any] ?? []
            if (plugin == "Utility") {
                utilityPlugin(callbackId: callbackId, method: "Utility." + method, parameters: parameters)
            } else if plugin == "Sqlite" {
                sqlitePlugin(callbackId: callbackId, method: "Sqlite." + method, parameters: parameters)
            } else if plugin == "AWS" {
                awsPlugin(callbackId: callbackId, method: "AWS." + method, parameters: parameters)
            } else if plugin == "AudioPlayer" {
                audioPlayerPlugin(callbackId: callbackId, method: "AudioPlayer." + method, parameters: parameters)
            } else if plugin == "VideoPlayer" {
                videoPlayerPlugin(callbackId: callbackId, method: "VideoPlayer." + method, parameters: parameters)
            } else {
                jsError(callbackId: callbackId, method: method, error: "Unknown plugin")
            }
        } else {
            // Simply log anything else that arrives
            print("JS ***** \(didReceive.body)")
        }
    }
    
    private func utilityPlugin(callbackId: String, method: String, parameters: [Any]) {
        
        if method == "Utility.locale" {
            let locale = Locale.current
            let locStr: String = locale.identifier
            let ident: String = locStr.replacingOccurrences(of: "_", with: "-", options: .literal, range: nil)
            let language: String? = locale.languageCode
            let script: String? = locale.scriptCode
            let country: String? = locale.regionCode
            let result = [ident, language, script, country]
            jsSuccess(callbackId: callbackId, method: method, response: result)
            
        } else if method == "Utility.platform" {
            jsSuccess(callbackId: callbackId, response: "iOS")
            
        } else if method == "Utility.modelType" {
            jsSuccess(callbackId: callbackId, response: UIDevice.current.model)
            
        } else if method == "Utility.modelName" {
            let modelName = DeviceSettings.modelName()
            jsSuccess(callbackId: callbackId, response: modelName)
            
        } else if method == "Utility.deviceSize" {
            let deviceSize = DeviceSettings.deviceSize()
            jsSuccess(callbackId: callbackId, response: deviceSize)
            
        } else if method == "Utility.hideKeyboard" {
            let hidden = self.controller.webview.endEditing(true)
            jsSuccess(callbackId: callbackId, response: hidden)
            
        } else {
            jsError(callbackId: callbackId, method: method, error: "unknown method")
        }
    }
    
    private func sqlitePlugin(callbackId: String, method: String, parameters: [Any]) {
        
        if method == "Sqlite.openDB" {
            if parameters.count == 2 {
                let dbname = parameters[0] as? String ?? "notString"
                let isCopyDatabase = parameters[1] as? Bool ?? true
                do {
                    try Sqlite3.openDB(dbname: dbname, copyIfAbsent: isCopyDatabase)
                    jsSuccess(callbackId: callbackId)
                } catch let err {
                    jsError(callbackId: callbackId, method: method, error: err.localizedDescription)
                }
            } else {
                jsError(callbackId: callbackId, method: method, error: "Must have two parameters")
            }
            
        } else if method == "Sqlite.queryJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    let result: [Dictionary<String,Any?>] = try db.queryV0(sql: statement, values: values)
                    jsSuccess(callbackId: callbackId, method: method, response: result)
                } catch let err {
                    jsError(callbackId: callbackId, method: method, error: err.localizedDescription, defaultVal: [])
                }
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have three parameters", defaultVal: [])
            }
            
        } else if method == "Sqlite.queryHTML" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    let result1: String = try db.queryHTML(sql: statement, values: values)
                    let result2: String = result1.replacingOccurrences(of: "\r", with: "\\r")
                    let result3: String = result2.replacingOccurrences(of: "\n", with: "\\n")
                    jsSuccess(callbackId: callbackId, response: result3)
                } catch let err {
                    jsError(callbackId: callbackId, method: method, error: err.localizedDescription, defaultVal: [])
                }
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have three parameters", defaultVal: [])
            }
            
        } else if method == "Sqlite.executeJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    let result: Int = try db.executeV1(sql: statement, values: values)
                    jsSuccess(callbackId: callbackId, response: result)
                } catch let err {
                    jsError(callbackId: callbackId, method: method, error: err.localizedDescription, defaultVal: 0)
                }
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have three parameters", defaultVal: 0)
            }
            
        } else if method == "Sqlite.bulkExecuteJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [[Any]] ?? [[]]
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    let result: Int = try db.bulkExecuteV1(sql: statement, values: values)
                    jsSuccess(callbackId: callbackId, response: result)
                } catch let err {
                    jsError(callbackId: callbackId, method: method, error: err.localizedDescription, defaultVal: 0)
                }
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have three parameters", defaultVal: 0)
            }
            
        } else if method == "Sqlite.closeDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                Sqlite3.closeDB(dbname: dbname)
                jsSuccess(callbackId: callbackId)
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have one parameter")
            }
            
        } else if method == "Sqlite.listDB" {
            do {
                let result: [String] = try Sqlite3.listDB()
                jsSuccess(callbackId: callbackId, method: method, response: result)
            } catch let err {
                jsError(callbackId: callbackId, method: method, error: err.localizedDescription, defaultVal: [])
            }
            
        } else if method == "Sqlite.deleteDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                do {
                    try Sqlite3.deleteDB(dbname: dbname)
                    jsSuccess(callbackId: callbackId)
                } catch let err {
                    jsError(callbackId: callbackId, method: method, error: err.localizedDescription)
                }
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have one parameter")
            }
        } else {
            jsError(callbackId: callbackId, method: method, error: "unknown method")
        }
    }
    
    private func awsPlugin(callbackId: String, method: String, parameters: [Any]) {
        
        if method == "AWS.downloadZipFile" {
            if parameters.count == 4 {
                let regionType = parameters[0] as? String ?? "notString"
                let s3Bucket = parameters[1] as? String ?? "notString"
                let s3Key = parameters[2] as? String ?? "notString"
                let filePath = parameters[3] as? String ?? "notString"
                let fileURL = URL(fileURLWithPath: NSHomeDirectory() + filePath)
                var s3: AwsS3? = nil
                if regionType == "SS" {
                    s3 = AwsS3Manager.findSS()
                } else if regionType == "DBP" {
                    s3 = AwsS3Manager.findDbp()
                } else if regionType == "TEST" {
                    s3 = AwsS3Manager.findTest()
                } else {
                    jsError(callbackId: callbackId, method: method, error: "Region must be SS, DBP, or TEST")
                }
                if let awsS3 = s3 {
                    awsS3.downloadZipFile(s3Bucket: s3Bucket, s3Key: s3Key, filePath: fileURL, view: nil,
                                          complete: { err in
                                            if let err1 = err {
                                                self.jsError(callbackId: callbackId, method: method, error: err1.localizedDescription)
                                            } else {
                                                self.jsSuccess(callbackId: callbackId)
                                            }
                    })
                }
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have three parameters")
            }
        } else {
            jsError(callbackId: callbackId, method: method, error: "unknown method")
        }
    }
    
    private func audioPlayerPlugin(callbackId: String, method: String, parameters: [Any]) {
        
        // NOTE: I don't know why this is asynchronous.  It is only a database query.  I should time it.
        if method == "AudioPlayer.findAudioVersion" {
            if parameters.count == 2 {
                let audioController = AudioBibleController.shared
                audioController.findAudioVersion(
                    version: parameters[0] as? String ?? "notString",
                    silLang: parameters[1] as? String ?? "notString",
                    complete: { bookIdList in
                        self.jsSuccess(callbackId: callbackId, response: bookIdList)
                })
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have two parameters", defaultVal: "")
            }
            
        } else if method == "AudioPlayer.isPlaying" {
            let audioController = AudioBibleController.shared
            let result: String = (audioController.isPlaying()) ? "T" : "F"
            jsSuccess(callbackId: callbackId, response: result)
            
        } else if method == "AudioPlayer.present" {
            if parameters.count == 2 {
                let audioController = AudioBibleController.shared
                audioController.present(view: controller.webview,
                                        book: parameters[0] as? String ?? "notString",
                                        chapterNum: parameters[1] as? Int ?? 1,
                                        complete: { error in
                                            // No error is actually being returned
                                            if let err = error {
                                                self.jsError(callbackId: callbackId, method: method,
                                                             error: err.localizedDescription)
                                            } else {
                                                self.jsSuccess(callbackId: callbackId)
                                            }
                })
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have two parameters")
            }
            
        } else if method == "AudioPlayer.stop" {
            let audioController = AudioBibleController.shared
            audioController.stop()
            jsSuccess(callbackId: callbackId)
            
        } else {
            jsError(callbackId: callbackId, method: method, error: "unknown method")
        }
    }
    
    private func videoPlayerPlugin(callbackId: String, method: String, parameters: [Any]) {
        
        if method == "VideoPlayer.showVideo" {
            if parameters.count == 5 {
                let player = VideoViewPlayer(mediaSource: parameters[0] as? String ?? "notString",
                                             videoId: parameters[1] as? String ?? "notString",
                                             languageId: parameters[2] as? String ?? "notString",
                                             silLang: parameters[3] as? String ?? "notString",
                                             videoUrl: parameters[4] as? String ?? "notString")
                self.videoViewPlayer = player
                player.begin(complete: { error in
                    if let err = error {
                        self.jsError(callbackId: callbackId, method: method, error: err.localizedDescription)
                    } else {
                        self.jsSuccess(callbackId: callbackId)
                    }
                })
                self.controller.present(player.controller, animated: true)
            } else {
                jsError(callbackId: callbackId, method: method, error: "must have five parameters")
            }
        } else {
            jsError(callbackId: callbackId, method: method, error: "unknown method")
        }
    }
    
    /**
     * Success Callbacks
     */
    private func jsSuccess(callbackId: String) {
        jsCallback(callbackId: callbackId, json: false, error: nil, response: "null")
    }
    
    private func jsSuccess(callbackId: String, response: Int) {
        jsCallback(callbackId: callbackId, json: false, error: nil, response: String(response))
    }
    
    private func jsSuccess(callbackId: String, response: Bool) {
        jsCallback(callbackId: callbackId, json: false, error: nil, response: String(response))
    }
    
    private func jsSuccess(callbackId: String, response: String?) {
        if let result1 = response {
            let result2 = "\"" + result1.replacingOccurrences(of: "\"", with: "\\\"") + "\""
            jsCallback(callbackId: callbackId, json: false, error: nil, response: result2)
        } else {
            jsCallback(callbackId: callbackId, json: false, error: nil, response: "null")
        }
    }
    
    private func jsSuccess(callbackId: String, method: String, response: [Any?]) {
        do {
            let message: String = try convertToJSON(response: response)
            jsCallback(callbackId: callbackId, json: true, error: nil, response: "\"" + message + "\"")
        } catch let jsonErr {
            let error = logError(method: method, message: jsonErr.localizedDescription)
            jsCallback(callbackId: callbackId, json: false, error: error, response: "null")
        }
    }
    
    /**
     * Error Callbacks
     */
    private func jsError(callbackId: String, method: String, error: String) {
        let err = logError(method: method, message: error)
        jsCallback(callbackId: callbackId, json: false, error: err, response: "null")
    }
    
    private func jsError(callbackId: String, method: String, error: String, defaultVal: Bool) {
        let err = logError(method: method, message: error)
        jsCallback(callbackId: callbackId, json: false, error: err, response: String(defaultVal))
    }
    
    private func jsError(callbackId: String, method: String, error: String, defaultVal: Int) {
        let err = logError(method: method, message: error)
        jsCallback(callbackId: callbackId, json: false, error: err, response: String(defaultVal))
    }
    
    private func jsError(callbackId: String, method: String, error: String, defaultVal: String) {
        let err = logError(method: method, message: error)
        let response = "'" + defaultVal + "'"
        jsCallback(callbackId: callbackId, json: false, error: err, response: response)
    }
    
    private func jsError(callbackId: String, method: String, error: String, defaultVal: [Any?]) {
        do {
            let message: String = try convertToJSON(response: defaultVal)
            let err = logError(method: method, message: error)
            jsCallback(callbackId: callbackId, json: true, error: err, response: "'" + message + "'")
        } catch let jsonErr {
            let error = logError(method: method, message: jsonErr.localizedDescription)
            jsCallback(callbackId: callbackId, json: false, error: error, response: "null")
        }
    }
    
    /**
     * This is a work in progress to know what conversions must be done to the string.
     */
    private func convertToJSON(response: [Any?]) throws -> String {
        do {
            let message: Data = try JSONSerialization.data(withJSONObject: response)
            if let result1 = String(data: message, encoding: String.Encoding.utf8) {
                let result2 = result1.replacingOccurrences(of: "\"", with: "\\\"", options: .literal)
                let result3 = result2.replacingOccurrences(of: "\\\\\"", with: "\\\"", options: .literal)
                return result3
            } else {
                return ""
            }
        }
    }
    
    private func jsCallback(callbackId: String, json: Bool, error: String?, response: String) {
        let isJson: Int = (json) ? 1 : 0
        let err = (error != nil) ? "'" + error! + "'" : "null"
        let message = "handleNative('\(callbackId)', \(isJson), \(err), \(response));"
        print("RETURN TO JS: \(message)")
        self.controller.webview.evaluateJavaScript(message, completionHandler: { data, error in
            if let err = error {
                print("jsCallbackError \(err)")
            }
            if let resp = data {
                print("jsCallback has unexpected response \(resp)")
            }
        })
    }
    
    private func logError(method: String, message: String) -> String {
        let error = "PLUGIN ERROR: \(method): \(message)"
        print(error)
        return error
    }
}
