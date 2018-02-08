//
//  AudioBibleState.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/16/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import CoreMedia

/**
 * This class persists the mediaId, mediaUrl and position (time) so that any media
 * can be restarted from the last place that it was viewed or heard.
 */
class AudioPlayState : NSObject, NSCoding {
    
    // Where is this stuff being stored? is should be Library/Caches
    static let stateDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static var currentState = AudioPlayState(mediaId: "XXX")
    
    static func retrieve(mediaId: String) -> AudioPlayState {
        let archiveURL = stateDirectory.appendingPathComponent(mediaId)
        let state = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? AudioPlayState
        currentState = (state != nil) ? state! : AudioPlayState(mediaId: mediaId)
        return currentState
    }
    
    static func clear() {
        currentState.mediaUrl = nil
        currentState.position = kCMTimeZero
        currentState.timestamp = Date()
        let archiveURL = stateDirectory.appendingPathComponent(currentState.mediaId)
        NSKeyedArchiver.archiveRootObject(currentState, toFile: archiveURL.path)
    }
    
    static func update(url: String, time: CMTime) {
        currentState.mediaUrl = url
        currentState.position = time
        currentState.timestamp = Date()
        let archiveURL = stateDirectory.appendingPathComponent(currentState.mediaId)
        NSKeyedArchiver.archiveRootObject(currentState, toFile: archiveURL.path)
    }
    
    var mediaId: String
    var mediaUrl: String?
    var position: CMTime
    var timestamp: Date
    
    init(mediaId: String, mediaUrl: String?, position: CMTime, timestamp: Date) {
        self.mediaId = mediaId
        self.mediaUrl = mediaUrl
        self.position = position
        self.timestamp = timestamp
    }
    
    init(mediaId: String) {
        self.mediaId = mediaId
        self.mediaUrl = nil
        self.position = kCMTimeZero
        self.timestamp = Date()
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let mediaId = decoder.decodeObject(forKey: "mediaId") as? String
            else {
                return nil
        }
        let mediaUrl = decoder.decodeObject(forKey: "mediaUrl") as? String
        let position = decoder.decodeTime(forKey: "position") as CMTime
        var timestamp = decoder.decodeObject(forKey: "timestamp") as? Date
        if (timestamp == nil) {
            timestamp = Date()
        }
        self.init(mediaId: mediaId, mediaUrl: mediaUrl, position: position, timestamp: timestamp!)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.mediaId, forKey: "mediaId")
        coder.encode(self.mediaUrl, forKey: "mediaUrl")
        coder.encode(self.position, forKey: "position")
        coder.encode(self.timestamp, forKey: "timestamp")
    }
    
    func toString() -> String {
        let result = "MediaId: \(self.mediaId), VideoUrl: \(self.mediaUrl ?? ""), Position: \(self.position), Timestamp: \(self.timestamp)"
        return result
    }
}
