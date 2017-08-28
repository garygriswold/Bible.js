//
//  AnalyticsSessionId.swift
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

class AnalyticsSessionId {
    
    static let SESSION_KEY: String = "ShortSandsSessionId"
    
    let archiveURL: URL
    
    init() {
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        let cacheDir = libDir.appendingPathComponent("Caches")
        archiveURL = cacheDir.appendingPathComponent(AnalyticsSessionId.SESSION_KEY)
    }
    
    deinit {
        print("AnalyticsSessionId is deallocated.")
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
    
    /**
     * Deprecated.  This is a method for getting sessionId from an external source, but I decided
     * that the timing of this query to a distinct non-AWS source, could become a signature, and
     * so it was abandoned.
     */
    private func getNewSessionIdDeprecated(complete: @escaping (_ sessionId:String) -> Void) {
        let url = URL(string: "https://www.uuidgenerator.net/api/version1")!
        let session = URLSession.shared
        let task = session.dataTask(with: url) {
            data, response, error in
            if let err = error {
                print(err.localizedDescription)
                complete(UUID().uuidString)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let guid = String(data: data!, encoding: String.Encoding.ascii)
                    complete(guid!)
                }
            } else {
                print("Unexpected state in getNewSessionId! Create UUID instead")
                complete(UUID().uuidString)
            }
        }
        task.resume()
    }
}


