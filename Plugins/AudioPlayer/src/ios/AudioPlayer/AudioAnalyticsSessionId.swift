//
//  AudioAnalyticsSessionId.swift
//  AnalyticsProto
//
//  Created by Gary Griswold on 6/6/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
/**
 * Originally, this class was going to get new sessionId's from a single external source in order
 * to guarantee uniqueness.  However, I decided that the sequence of events including some access of
 * to that server followed by other access to AWS could in itself become a signature that could be
 * tracked.  I instead use a random number UUID.  Using a more official GUID would be better at
 * guranteeing uniqueness, but it might be possible for someone to identify a MAC address from
 * that kind of GUID. So, I use a random number UUID, i.e. version 4.  For the purpose this
 * sessionId serves, it will not cause much of a problem if identical sessionIds are created on
 * some rare occasion.  Gary Griswold June 7, 2017
 *
 * NOTE: A nearly identical class exists in the Video Player.  This one has been updated to use Library/Caches
 */
import Foundation

class AudioAnalyticsSessionId {
    
    private static let SESSION_KEY: String = "ShortSandsSessionId"
    
    private let archiveURL: URL
    
    init() {
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        let cacheDir = libDir.appendingPathComponent("Caches")
        archiveURL = cacheDir.appendingPathComponent(AudioAnalyticsSessionId.SESSION_KEY)
    }
    
    deinit {
        print("***** Deinit AudioAnalyticsSessionId *****")
    }
    
    func getSessionId() -> String {
        let sessionId: String? = retrieveSessionId()
        if (sessionId != nil) {
            return sessionId!
        } else {
            let newSessionId = UUID().uuidString
            self.saveSessionId(sessionId: newSessionId)
            return newSessionId
        }
    }
    
    private func retrieveSessionId() -> String? {
        let sessionId = NSKeyedUnarchiver.unarchiveObject(withFile: self.archiveURL.path) as? String
        return sessionId
    }
    
    private func saveSessionId(sessionId: String) -> Void {
        NSKeyedArchiver.archiveRootObject(sessionId, toFile: self.archiveURL.path)
    }
}


