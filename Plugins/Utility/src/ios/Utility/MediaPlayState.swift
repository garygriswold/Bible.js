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
            return CMTimeMake(self.positionMS, 1000)
        }
        set(newPosition) {
            self.positionMS = Int64(CMTimeGetSeconds(newPosition))
        }
    }
    public var timestamp: Date {
        get {
            let interval = TimeInterval(Double(self.timestampMS) / 1000.0)
            return Date(timeIntervalSince1970: interval)
        }
        set(newTime) {
            
            self.timestampMS = Int64(newTime.timeIntervalSinceNow * 1000.0)
        }
    }
    
    init(mediaType: String) {
        self.mediaType = mediaType
        self.mediaId = "unknown"
        self.mediaUrl = ""
        self.positionMS = 0
        self.timestampMS = Int64(Date().timeIntervalSince1970 * 1000.0)
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
        self.timestampMS = now()
    }
    
    func update(mediaUrl: String, position: CMTime) {
        self.mediaUrl = mediaUrl
        self.position = position
        self.timestampMS = now()
    }
    
    func getKey() -> [String] {
        return [self.mediaType, self.mediaId]
    }
    
    func getDBFields() -> [Any] {
        return [self.mediaType, self.mediaId, self.mediaUrl, self.positionMS, self.timestampMS]
    }

    private func now() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000.0)
    }
}
