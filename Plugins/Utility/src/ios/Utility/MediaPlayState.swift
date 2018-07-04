//
//  MediaPlayState.swift
//  Utility
//
//  Created by Gary Griswold on 7/3/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import CoreMedia

public class MediaPlayState {
    
    public let mediaType: String
    public var mediaId: String
    public var mediaUrl: String
    public var positionMS: Int64
    public var timestampMS: Int64
    public var position: CMTime {
        get {
            //let time: CMTime = CMTimeMake(self.positionMS, 1000)
            //let ms: Int64 = Int64(CMTimeGetSeconds(time) * 1000)
            //if (self.positionMS != ms) {
            //    print("ERROR")
            //}
            return CMTimeMake(self.positionMS, 1000)
        }
        set(newPosition) {
            self.positionMS = Int64(CMTimeGetSeconds(newPosition) * 1000)
        }
    }
    public var timestamp: Date {
        get {
            //let inter = TimeInterval(Double(self.timestampMS) / 1000.0)
            //let d: Date = Date(timeIntervalSince1970: inter)
            //let ms = Int64(d.timeIntervalSince1970 * 1000.0)
            //if (self.timestampMS != ms) {
            //    print("ERROR")
            //}
            let interval = TimeInterval(Double(self.timestampMS) / 1000.0)
            return Date(timeIntervalSince1970: interval)
        }
        set(newTime) {
            self.timestampMS = Int64(newTime.timeIntervalSince1970 * 1000.0)
        }
    }
    
    init(mediaType: String) {
        self.mediaType = mediaType
        self.mediaId = "unknown"
        self.mediaUrl = ""
        self.positionMS = 0
        self.timestampMS = MediaPlayState.now()
    }
    
    deinit {
        print("****** deinit MediaPlayState ******")
    }
    
    func clear() {
        self.clear(mediaId: "unknown")
    }
    
    func clear(mediaId: String) {
        self.mediaId = mediaId
        self.mediaUrl = ""
        self.positionMS = 0
        self.timestampMS = MediaPlayState.now()
    }
    
    func update(mediaUrl: String, position: CMTime) {
        self.mediaUrl = mediaUrl
        self.position = position
        self.timestampMS = MediaPlayState.now()
    }
    
    func getKey() -> [String] {
        return [self.mediaType, self.mediaId]
    }
    
    func getDBFields() -> [Any] {
        return [self.mediaType, self.mediaId, self.mediaUrl, self.positionMS, self.timestampMS]
    }
    
    public func dump() {
        print("mediaType \(mediaType)")
        print("mediaId   \(mediaId)")
        print("mediaUrl  \(mediaUrl)")
        print("position  \(position)  \(positionMS)")
        print("timestamp \(timestamp) \(timestampMS)")
    }

    public static func now() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000.0)
    }
}
