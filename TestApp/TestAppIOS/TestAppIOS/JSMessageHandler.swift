//
//  JSMessageHandler.swift
//  TestAppIOS
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
        print("CALL FROM JS: \(didReceive.body)")
        if didReceive.body is Dictionary<String, Any> {
            let request = (didReceive.body as? Dictionary<String, Any>)!
            let plugin = request["plugin"] as? String ?? "notString"
            let method = request["method"] as? String ?? "notString"
            let parameters = request["parameters"] as? [Any] ?? []
            let callbackId = request["callbackId"] as? String ?? "notString"
            if (plugin == "Utility") {
                utilityPlugin(method: method, parameters: parameters, callbackId: callbackId)
            } else if plugin == "Sqlite" {
                sqlitePlugin(method: method, parameters: parameters, callbackId: callbackId)
            } else if plugin == "AWS" {
                awsPlugin(method: method, parameters: parameters, callbackId: callbackId)
            } else if plugin == "AudioPlayer" {
                audioPlayerPlugin(method: method, parameters: parameters, callbackId: callbackId)
            } else if plugin == "VideoPlayer" {
                videoPlayerPlugin(method: method, parameters: parameters, callbackId: callbackId)
            } else {
                jsError(callbackId: callbackId, plugin: plugin, method: method, error: "Unknown plugin")
            }
        } else {
            print("Message set to callNative, must be a dictionary")
            // I think there is no other error response possible here.
        }
    }
    
    private func utilityPlugin(method: String, parameters: [Any], callbackId: String) {
        
        if method == "locale" {
            let locale = Locale.current
            let localeStr = locale.identifier
            let language = locale.languageCode
            let script = locale.scriptCode
            let country = locale.regionCode
            print("locale \(localeStr)")
            let result = [localeStr, language, script, country]
            jsSuccess(callbackId: callbackId, plugin: "Utility", method: method, response: result)
            
        } else if method == "platform" {
            jsSuccess(callbackId: callbackId, response: "iOS")
            
        } else if method == "modelType" {
            jsSuccess(callbackId: callbackId, response: UIDevice.current.model)
            
        } else if method == "modelName" {
            let modelName = DeviceSettings.modelName()
            jsSuccess(callbackId: callbackId, response: modelName)
            
        } else if method == "deviceSize" {
            let deviceSize = DeviceSettings.deviceSize()
            jsSuccess(callbackId: callbackId, response: deviceSize)
            
        } else if method == "hideKeyboard" {
            let hidden = self.controller.webview.endEditing(true)
            jsSuccess(callbackId: callbackId, response: hidden)
            
        } else {
            jsError(callbackId: callbackId, plugin: "Utility", method: method, error: "unknown method")
        }
    }
    
    private func sqlitePlugin(method: String, parameters: [Any], callbackId: String) {
        //var error: String? = nil
        
        if method == "openDB" {
            if parameters.count == 2 {
                let dbname = parameters[0] as? String ?? "notString"
                let isCopyDatabase = parameters[1] as? Bool ?? true
                do {
                    try Sqlite3.openDB(dbname: dbname, copyIfAbsent: isCopyDatabase)
                    jsSuccess(callbackId: callbackId)
                } catch let err {
                    jsError(callbackId: callbackId, plugin: "Sqlite", method: method, error: err.localizedDescription)
                }
            } else {
                jsError(callbackId: callbackId, plugin: "Sqlite", method: method, error: "Must have two parameters")
            }
            
        } else if method == "queryJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    let result: [Dictionary<String,Any?>] = try db.queryV0(sql: statement, values: values)
                    jsSuccess(callbackId: callbackId, plugin: "Sqlite", method: method, response: result)
                } catch let err {
                    jsError(callbackId: callbackId, plugin: "Sqlite", method: method,
                            error: err.localizedDescription, defaultVal: [])
                }
            } else {
                jsError(callbackId: callbackId, plugin: "Sqlite", method: method,
                        error: "must have three parameters", defaultVal: [])
            }
            
        } else if method == "executeJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    let result: Int = try db.executeV1(sql: statement, values: values)
                    jsSuccess(callbackId: callbackId, response: result)
                } catch let err {
                    jsError(callbackId: callbackId, plugin: "Sqlite", method: method,
                            error: err.localizedDescription, defaultVal: 0)
                }
            } else {
                jsError(callbackId: callbackId, plugin: "Sqlite", method: method,
                        error: "must have three parameters", defaultVal: 0)
            }
            
        } else if method == "bulkExecuteJS" {
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [[Any]] ?? [[]]
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    let result: Int = try db.bulkExecuteV1(sql: statement, values: values)
                    jsSuccess(callbackId: callbackId, response: result)
                } catch let err {
                    jsError(callbackId: callbackId, plugin: "Sqlite", method: method,
                            error: err.localizedDescription, defaultVal: 0)
                }
            } else {
                jsError(callbackId: callbackId, plugin: "Sqlite", method: method,
                        error: "must have three parameters", defaultVal: 0)
            }
            
        } else if method == "closeDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                Sqlite3.closeDB(dbname: dbname)
                jsSuccess(callbackId: callbackId)
            } else {
                jsError(callbackId: callbackId, plugin: "Sqlite", method: method, error: "must have one parameter")
            }

        } else if method == "listDB" {
            do {
                let result: [String] = try Sqlite3.listDB()
                jsSuccess(callbackId: callbackId, plugin: "Sqlite", method: method, response: result)
            } catch let err {
                jsError(callbackId: callbackId, plugin: "Sqlite", method: method,
                           error: err.localizedDescription, defaultVal: [])
            }
            
        } else if method == "deleteDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                do {
                    try Sqlite3.deleteDB(dbname: dbname)
                    jsSuccess(callbackId: callbackId)
                } catch let err {
                    jsError(callbackId: callbackId, plugin: "Sqlite", method: method, error: err.localizedDescription)
                }
            } else {
                jsError(callbackId: callbackId, plugin: "Sqlite", method: method, error: "must have one parameter")
            }
        } else {
            jsError(callbackId: callbackId, plugin: "Sqlite", method: method, error: "unknown method")
        }
    }
    
    private func awsPlugin(method: String, parameters: [Any], callbackId: String) {

        if method == "downloadZipFile" {
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
                    jsError(callbackId: callbackId, plugin: "AWS", method: method,
                            error: "Region must be SS, DBP, or TEST")
                }
                if let awsS3 = s3 {
                    awsS3.downloadZipFile(s3Bucket: s3Bucket, s3Key: s3Key, filePath: fileURL, view: nil,
                                          complete: { err in
                        if let err1 = err {
                            self.jsError(callbackId: callbackId, plugin: "AWS", method: method,
                                        error: err1.localizedDescription)
                        } else {
                            self.jsSuccess(callbackId: callbackId)
                        }
                    })
                }
            } else {
                jsError(callbackId: callbackId, plugin: "AWS", method: method, error: "must have three parameters")
            }
        } else {
            jsError(callbackId: callbackId, plugin: "AWS", method: method, error: "unknown method")
        }
    }
    
    private func audioPlayerPlugin(method: String, parameters: [Any], callbackId: String) {
        
        if method == "findAudioVersion" {
            if parameters.count == 2 {
                let audioController = AudioBibleController.shared
                audioController.findAudioVersion(
                    version: parameters[0] as? String ?? "notString",
                    silLang: parameters[1] as? String ?? "notString",
                    complete: { bookIdList in
                        self.jsSuccess(callbackId: callbackId, response: bookIdList)
                })
            } else {
                jsError(callbackId: callbackId, plugin: "AudioPlayer", method: method,
                           error: "must have two parameters", defaultVal: "")
            }

        } else if method == "isPlaying" {
            let audioController = AudioBibleController.shared
            let result: String = (audioController.isPlaying()) ? "T" : "F"
            jsSuccess(callbackId: callbackId, response: result)
            
        } else if method == "present" {
            if parameters.count == 2 {
                let audioController = AudioBibleController.shared
                audioController.present(view: controller.webview,
                                        book: parameters[0] as? String ?? "notString",
                                        chapterNum: parameters[1] as? Int ?? 1,
                                        complete: { error in
                                            // No error is actually being returned
                                            if let err = error {
                                                self.jsError(callbackId: callbackId, plugin: "AudioPlayer",
                                                             method: method, error: err.localizedDescription)
                                            } else {
                                                self.jsSuccess(callbackId: callbackId)
                                            }
                })
            } else {
                jsError(callbackId: callbackId, plugin: "AudioPlayer", method: method,
                        error: "must have two parameters")
            }
        
        } else if method == "stop" {
            let audioController = AudioBibleController.shared
            audioController.stop()
            jsSuccess(callbackId: callbackId)
            
        } else {
            jsError(callbackId: callbackId, plugin: "AudioPlayer", method: method, error: "unknown method")
        }
    }
    
    private func videoPlayerPlugin(method: String, parameters: [Any], callbackId: String) {
        
        if method == "showVideo" {
            if parameters.count == 5 {
                let player = VideoViewPlayer(mediaSource: parameters[0] as? String ?? "notString",
                                             videoId: parameters[1] as? String ?? "notString",
                                             languageId: parameters[2] as? String ?? "notString",
                                             silLang: parameters[3] as? String ?? "notString",
                                             videoUrl: parameters[4] as? String ?? "notString")
                self.videoViewPlayer = player
                player.begin(complete: { error in
                    if let err = error {
                        self.jsError(callbackId: callbackId, plugin: "VideoPlayer", method: method,
                                     error: err.localizedDescription)
                    } else {
                        self.jsSuccess(callbackId: callbackId)
                    }
                })
                self.controller.present(player.controller, animated: true)
            } else {
                jsError(callbackId: callbackId, plugin: "VideoPlayer", method: method,
                        error: "must have five parameters")
            }
        } else {
            jsError(callbackId: callbackId, plugin: "VideoPlayer", method: method, error: "unknown method")
        }
    }
    
    /**
    * Success Callbacks
    */
    private func jsSuccess(callbackId: String) {
        rawCallback(callbackId: callbackId, json: false, error: nil, response: "null")
    }
    
    private func jsSuccess(callbackId: String, response: Int) {
        rawCallback(callbackId: callbackId, json: false, error: nil, response: String(response))
    }
    
    private func jsSuccess(callbackId: String, response: Bool) {
        rawCallback(callbackId: callbackId, json: false, error: nil, response: String(response))
    }
    
    private func jsSuccess(callbackId: String, response: String?) {
        let result: String = (response != nil) ? "'" + response! + "'" : "null"
        rawCallback(callbackId: callbackId, json: false, error: nil, response: result)
    }
    
    private func jsSuccess(callbackId: String, plugin: String, method: String, response: [Any?]) {
        do {
            let message: Data = try JSONSerialization.data(withJSONObject: response)
            let result = "'" + String(data: message, encoding: String.Encoding.utf8)! + "'"
            rawCallback(callbackId: callbackId, json: true, error: nil, response: result)
        } catch let jsonError {
            let error = logError(plugin: plugin, method: method, message: jsonError.localizedDescription)
            rawCallback(callbackId: callbackId, json: false, error: error, response: "null")
        }
    }
    
    /**
    * Error Callbacks
    */
    private func jsError(callbackId: String, plugin: String, method: String, error: String) {
        let err = logError(plugin: plugin, method: method, message: error)
        rawCallback(callbackId: callbackId, json: false, error: err, response: "null")
    }
    
    private func jsError(callbackId: String, plugin: String, method: String, error: String, defaultVal: Bool) {
        let err = logError(plugin: plugin, method: method, message: error)
        rawCallback(callbackId: callbackId, json: false, error: err, response: String(defaultVal))
    }
    
    private func jsError(callbackId: String, plugin: String, method: String, error: String, defaultVal: Int) {
        let err = logError(plugin: plugin, method: method, message: error)
        rawCallback(callbackId: callbackId, json: false, error: err, response: String(defaultVal))
    }
    
    private func jsError(callbackId: String, plugin: String, method: String, error: String, defaultVal: String) {
        let err = logError(plugin: plugin, method: method, message: error)
        let response = "'" + defaultVal + "'"
        rawCallback(callbackId: callbackId, json: false, error: err, response: response)
    }
    
    private func jsError(callbackId: String, plugin: String, method: String, error: String,
                            defaultVal: [Any?]) {
        do {
            let message: Data = try JSONSerialization.data(withJSONObject: defaultVal)
            let result = "'" + String(data: message, encoding: String.Encoding.utf8)! + "'"
            rawCallback(callbackId: callbackId, json: true, error: error, response: result)
        } catch let jsonError {
            let error = logError(plugin: plugin, method: method, message: jsonError.localizedDescription)
            rawCallback(callbackId: callbackId, json: false, error: error, response: "null")
        }
    }
    
    private func rawCallback(callbackId: String, json: Bool, error: String?, response: Any) {
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
    
    private func logError(plugin: String, method: String, message: String) -> String {
        let error = "PLUGIN ERROR: \(plugin).\(method):  \(message)"
        print(error)
        return error
    }
}
