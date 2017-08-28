//
//  AudioAnalytics.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/25/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
import Foundation
import CoreMedia
import AWS

class AudioAnalytics {
    
    var dictionary = [String: String]()
    let dateFormatter = DateFormatter()
    
    let mediaSource: String
    let mediaId: String
    let languageId: String
    let silLang: String
    let sessionId: String
    
    // Pass following from play to playEnd
    var timeStarted: Date
    var startingPosition: Float64
    
    init(mediaSource: String,
         mediaId: String,
         languageId: String,
         silLang: String) {
        
        self.mediaSource = mediaSource
        self.mediaId = mediaId
        self.languageId = languageId
        self.silLang = silLang
        
        let analyticsSessionId = AnalyticsSessionId()
        self.sessionId = analyticsSessionId.getSessionId()
        
        self.timeStarted = Date()
        self.startingPosition = 0.0
        
        // ISO8601 DateFormatter (ios 10.3 has a function for this)
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        self.dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    deinit {
        print("***** Deinit AudioAnalytics *****")
    }
    
    func playStarted(item: String, position: CMTime) -> Void {
        self.dictionary.removeAll()
        self.dictionary["sessionId"] = self.sessionId
        self.dictionary["mediaSource"] = self.mediaSource
        self.dictionary["mediaId"] = self.mediaId
        self.dictionary["languageId"] = self.languageId
        self.dictionary["silLang"] = self.silLang
        
        let locale = Locale.current
        self.dictionary["language"] = locale.languageCode
        self.dictionary["country"] = locale.regionCode
        self.dictionary["locale"] = locale.identifier
        
        let device = UIDevice.current
        self.dictionary["deviceType"] = "mobile"
        self.dictionary["deviceFamily"] = "Apple"
        self.dictionary["deviceName"] = device.model
        self.dictionary["deviceOS"] = "ios"
        print("system name \(device.systemName)")
        self.dictionary["osVersion"] = device.systemVersion
        
        let bundle = Bundle.main
        let info = bundle.infoDictionary
        self.dictionary["appName"] = info?["CFBundleIdentifier"] as? String
        self.dictionary["appVersion"] = info?["CFBundleShortVersionString"] as? String
        
        self.timeStarted = Date()
        self.dictionary["timeStarted"] = dateFormatter.string(from: self.timeStarted)
        
        self.dictionary["isStreaming"] = "true" // should this be 1 instead
        self.dictionary["startingItem"] = item
        self.startingPosition = CMTimeGetSeconds(position)
        self.dictionary["startingPosition"] = String(round(self.startingPosition * 1000) / 1000)
        
        AwsS3.shared.uploadAnalytics(sessionId: self.sessionId,
                                     timestamp: self.dictionary["timeStarted"]! + "-B",
                                     prefix: "AudioBegV1",
                                     dictionary: self.dictionary, complete: { (error) in
                                        if let err = error {
                                            print("Error in upload analytics \(err)")
                                        }
        })
    }
    
    func playEnded(item: String, position: CMTime) {
        print("INSIDE PLAY END \(position)")
        self.dictionary.removeAll()
        self.dictionary["sessionId"] = self.sessionId
        self.dictionary["timeStarted"] = dateFormatter.string(from: self.timeStarted)
        let timeCompleted = Date()
        self.dictionary["timeCompleted"] = dateFormatter.string(from: timeCompleted)
        let duration: TimeInterval = timeCompleted.timeIntervalSince(self.timeStarted)
        self.dictionary["elapsedTime"] = String(round(duration * 1000) / 1000)
        self.dictionary["endingItem"] = item
        let endingPosition = CMTimeGetSeconds(position)
        self.dictionary["endingPosition"] = String(round(endingPosition * 1000) / 1000)
        
        AwsS3.shared.uploadAnalytics(sessionId: self.sessionId,
                                     timestamp: self.dictionary["timeCompleted"]! + "-E",
                                     prefix: "AudioEndV1",
                                     dictionary: self.dictionary,
                                     complete: { (error) in
                                        if let err = error {
                                            print("Error in upload of analytics \(err)")
                                        }
                                        
        })
    }
}

