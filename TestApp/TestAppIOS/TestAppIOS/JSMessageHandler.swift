//
//  JSMessageHandler.swift
//  TestAppIOS
//
//  Created by Gary Griswold on 5/10/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// It is essential when writing any new Plugin methods, to call logError for any error that occurs to
// ensure that it is logged in iOS.
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
                let error = logError(plugin: plugin, method: method, message: "Unknown plugin")
                jsCallback(callbackId: callbackId, error: error)
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
            jsCallbackJSON(callbackId: callbackId, plugin: "Utility", method: method, response: result)
            
        } else if method == "platform" {
            jsCallback(callbackId: callbackId, response: "iOS")
            
        } else if method == "modelType" {
            jsCallback(callbackId: callbackId, response: UIDevice.current.model)
            
        } else if method == "modelName" {
            let modelName = DeviceSettings.modelName()
            jsCallback(callbackId: callbackId, response: modelName)
            
        } else if method == "deviceSize" {
            let deviceSize = DeviceSettings.deviceSize()
            jsCallback(callbackId: callbackId, response: deviceSize)
            
        } else if method == "hideKeyboard" {
            let hidden = self.controller.webview.endEditing(true)
            jsCallback(callbackId: callbackId, response: hidden)
            
        } else {
            logError(plugin: "Utility", method: method, message: "unknown method")
            jsCallback(callbackId: callbackId, response: nil) // on error return nil
        }
    }
    
    private func sqlitePlugin(method: String, parameters: [Any], callbackId: String) {
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
            jsCallback(callbackId: callbackId, error: error) // if error, return error, else nil
            
        } else if method == "queryJS" {
            var result: [Dictionary<String,Any?>]
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    result = try db.queryV0(sql: statement, values: values)
                    jsCallbackJSON(callbackId: callbackId, plugin: "Sqlite", method: method,
                                   response: result)
                } catch let err {
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                    jsCallback(callbackId: callbackId, error: error)
                }
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have three parameters")
                jsCallback(callbackId: callbackId, error: error)
            }
            
        } else if method == "executeJS" {
            var result: Int = 0
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [Any] ?? []
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    result = try db.executeV1(sql: statement, values: values)
                    jsCallback(callbackId: callbackId, response: result)
                } catch let err {
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                    jsCallback(callbackId: callbackId, error: error)
                }
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have three parameters")
                jsCallback(callbackId: callbackId, error: error)
            }
            
        } else if method == "bulkExecuteJS" {
            var result: Int = 0
            if parameters.count == 3 {
                let dbname = parameters[0] as? String ?? "notString"
                let statement = parameters[1] as? String ?? "notString"
                let values = parameters[2] as? [[Any]] ?? [[]]
                do {
                    let db = try Sqlite3.findDB(dbname: dbname)
                    result = try db.bulkExecuteV1(sql: statement, values: values)
                    jsCallback(callbackId: callbackId, response: result)
                } catch let err {
                    error = logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
                    jsCallback(callbackId: callbackId, error: error)
                }
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have three parameters")
                jsCallback(callbackId: callbackId, error: error)
            }
            
        } else if method == "closeDB" {
            if parameters.count == 1 {
                let dbname = parameters[0] as? String ?? "notString"
                Sqlite3.closeDB(dbname: dbname)
            } else {
                error = logError(plugin: "Sqlite", method: method, message: "must have one parameter")
            }
            jsCallback(callbackId: callbackId, error: error) // if error, return error

        } else if method == "listDB" {
            var result: [String]
            do {
                result = try Sqlite3.listDB()
            } catch let err {
                result = []
                logError(plugin: "Sqlite", method: method, message: err.localizedDescription)
            }
            jsCallbackJSON(callbackId: callbackId, plugin: "Sqlite", method: method,
                           response: result)  // if error, return []
            
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
            jsCallback(callbackId: callbackId, error: error) // if error, return error, else nil
            
        } else {
            let error = logError(plugin: "Sqlite", method: method, message: "unknown method")
            jsCallback(callbackId: callbackId, error: error) // if error, return error
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
                    awsResponse(method: method, callbackId: callbackId, error: "Region must be SS, DBP, or TEST")
                }
                if let awsS3 = s3 {
                    awsS3.downloadZipFile(s3Bucket: s3Bucket, s3Key: s3Key, filePath: fileURL, view: nil,
                                          complete: { err in
                        if let err1 = err {
                            self.awsResponse(method: method, callbackId: callbackId, error: err1.localizedDescription)
                        } else {
                            self.awsResponse(method: method, callbackId: callbackId, error: nil)
                        }
                    })
                }
            } else {
                awsResponse(method: method, callbackId: callbackId, error: "must have three parameters")
            }
        } else {
            awsResponse(method: method, callbackId: callbackId, error: "unknown method")
        }
    }
    private func awsResponse(method: String, callbackId: String, error: String?) {
        var err: String? = nil
        if let err1 = error {
            err = logError(plugin: "AWS", method: method, message: err1)
        }
        jsCallback(callbackId: callbackId, error: err) // if error, return error
    }
    
    private func audioPlayerPlugin(method: String, parameters: [Any], callbackId: String) {
        var error: String? = nil
        
        if method == "findAudioVersion" {
            if parameters.count == 2 {
                let audioController = AudioBibleController.shared
                audioController.findAudioVersion(
                    version: parameters[0] as? String ?? "notString",
                    silLang: parameters[1] as? String ?? "notString",
                    complete: { bookIdList in
                        self.jsCallback(callbackId: callbackId, response: bookIdList)
                })
            } else {
                logError(plugin: "AudioPlayer", method: method, message: "must have two parameters")
                jsCallback(callbackId: callbackId, response: "") // if error, return ""
            }

        } else if method == "isPlaying" {
            let audioController = AudioBibleController.shared
            let result: String = (audioController.isPlaying()) ? "T" : "F"
            jsCallback(callbackId: callbackId, response: result) // if error, return "F"
            
        } else if method == "present" {
            if parameters.count == 2 {
                let audioController = AudioBibleController.shared
                audioController.present(view: controller.webview,
                                        book: parameters[0] as? String ?? "notString",
                                        chapterNum: parameters[1] as? Int ?? 1,
                                        complete: { error in
                                            // No error is actually being returned
                                            self.jsCallback(callbackId: callbackId, error: error?.localizedDescription)
                })
            } else {
                error = logError(plugin: "AudioPlayer", method: method, message: "must have two parameters")
                jsCallback(callbackId: callbackId, error: error) // if error, return error
            }
        
        } else if method == "stop" {
            let audioController = AudioBibleController.shared
            audioController.stop()
            jsCallback(callbackId: callbackId, error: error) // if error, return error
            
        } else {
            error = logError(plugin: "AudioPlayer", method: method, message: "unknown method")
            jsCallback(callbackId: callbackId, error: error) // if error, return error
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
                player.begin(complete: { err in
                    if let err1 = err {
                        self.videoResponse(method: method, callbackId: callbackId, error: err1.localizedDescription)
                    } else {
                        self.videoResponse(method: method, callbackId: callbackId, error: nil)
                    }
                })
                self.controller.present(player.controller, animated: true)
            } else {
                videoResponse(method: method, callbackId: callbackId, error: "must have five parameters")
            }
        } else {
            videoResponse(method: method, callbackId: callbackId, error: "unknown method")
        }
    }
    private func videoResponse(method: String, callbackId: String, error: String?) {
        if let err1 = error {
            let err = logError(plugin: "VideoPlayer", method: method, message: err1)
            jsCallback(callbackId: callbackId, error: err)
        }
        jsCallback(callbackId: callbackId, response: nil) // if error, return error
    }

    private func logError(plugin: String, method: String, message: String) -> String {
        let error = "PLUGIN ERROR: \(plugin).\(method):  \(message)"
        print(error)
        return error
    }
    
    func jsCallbackJSON(callbackId: String, plugin: String, method: String, response: [Any?]) {
        do {
            let message: Data = try JSONSerialization.data(withJSONObject: response)
            let result = "'" + String(data: message, encoding: String.Encoding.utf8)! + "'"
            rawCallback(callbackId: callbackId, json: true, error: "null", response: result)
        } catch let jsonError {
            let error = logError(plugin: plugin, method: method, message: jsonError.localizedDescription)
            rawCallback(callbackId: callbackId, json: false, error: error, response: "null")
        }
    }
    
    func jsCallback(callbackId: String, error: String?) {
        let err: String = (error != nil) ? "'" + error! + "'" : "null"
        rawCallback(callbackId: callbackId, json: false, error: err, response: "null")
    }
    
    func jsCallback(callbackId: String, response: Int) {
        rawCallback(callbackId: callbackId, json: false, error: "null", response: String(response))
    }
    
    func jsCallback(callbackId: String, response: Bool) {
        rawCallback(callbackId: callbackId, json: false, error: "null", response: String(response))
    }
    
    func jsCallback(callbackId: String, response: String?) {
        let result: String = (response != nil) ? "'" + response! + "'" : "null"
        rawCallback(callbackId: callbackId, json: false, error: "null", response: result)
    }
    
    func rawCallback(callbackId: String, json: Bool, error: String, response: Any) {
        let isJson: Int = (json) ? 1 : 0
        let message = "handleNative('\(callbackId)', \(isJson), \(error), \(response));"
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
}
