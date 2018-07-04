//
//  MediaPlayState.swift
//  Utility
//
//  Created by Gary Griswold on 7/3/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

/**
* This class is used by both audio and video files to store the current position of play.
* But, the use is slightly different for audio and video.  The mediaType identifies audio
* vs video.  The mediaId is the key to look up the position and timestamp.
*
* For video, mediaUrl does not change for a mediaId.  So, it does not really need to be stored,
* but, both VideoPlayers store the information in MediaPlayState for their processing.
*
* For audio, the mediaId refers to a version of the Bible, while the mediaUrl refers to a chapter.
* The mediaUrl must be stored with the other information.  When it is retrieved, the audio player
* much check to see if the chapter being played now is the last one saved.  If it is the same, then
* the saved position information should be used.
*/
import Foundation
import CoreMedia

public class MediaPlayState {
    
    public static let audio: MediaPlayState = MediaPlayState(mediaType: "audio")
    public static let video: MediaPlayState = MediaPlayState(mediaType: "video")
    
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
            self.positionMS = Int64(CMTimeGetSeconds(newPosition) * 1000)
        }
    }
    public var timestamp: Date {
        get {
            let interval = TimeInterval(Double(self.timestampMS) / 1000.0)
            return Date(timeIntervalSince1970: interval)
        }
        set(newTime) {
            self.timestampMS = Int64(newTime.timeIntervalSince1970 * 1000.0)
        }
    }
    
    private init(mediaType: String) {
        self.mediaType = mediaType
        self.mediaId = "unknown"
        self.mediaUrl = ""
        self.positionMS = 0
        self.timestampMS = MediaPlayState.now()
    }
    
    deinit {
        print("****** deinit MediaPlayState ******")
    }
    
    private func clear() {
        self.clear(mediaId: "unknown")
    }
    
    private func clear(mediaId: String) {
        self.mediaId = mediaId
        self.mediaUrl = ""
        self.positionMS = 0
        self.timestampMS = MediaPlayState.now()
    }
    
    public static func now() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000.0)
    }
    
    public func dump(location: String) {
        print(location + ": " + self.toString())
    }
    
    public func toString() -> String {
        let result = "MediaId: \(self.mediaId), MediaUrl: \(self.mediaUrl)," +
            " Position: \(self.position), Timestamp: \(self.timestamp)"
        return result
    }

    /**********************************************************************************************
    * Adapter Methods
    ***********************************************************************************************/
    
    public func retrieve(mediaId: String) {
        do {
            self.clear(mediaId: mediaId)
            if let db = self.findDB() {
                let sql = "SELECT mediaUrl, position, timestamp" +
                " FROM MediaState WHERE mediaType = ? AND mediaId = ?"
                let values = [self.mediaType, self.mediaId]
                let resultSet: [[String?]] = try db.queryV1(sql: sql, values: values)
                if (resultSet.count > 0) {
                    let row = resultSet[0];
                    self.mediaUrl = row[0] ?? "unknown"
                    self.positionMS = Int64(row[1] ?? "0") ?? 0
                    self.timestampMS = Int64(row[2] ?? "0") ?? MediaPlayState.now()
                }
            }
        } catch let err {
            handleError(caller: "MediaPlayState.retrieve", error: err)
        }
        self.dump(location: "retrieve")
    }
    
    public func update(position: CMTime) {
        update(mediaUrl: self.mediaUrl, position: position)
    }
    
    public func update(mediaUrl: String, position: CMTime) {
        do {
            if (self.mediaUrl != "") {
                self.mediaUrl = mediaUrl
                self.position = position
                self.timestampMS = MediaPlayState.now()
                if let db = self.findDB() {
                    let sql = "REPLACE INTO MediaState(mediaType, mediaId, mediaUrl, position, timestamp)" +
                    " VALUES (?, ?, ?, ?, ?)"
                    let values: [Any] = [self.mediaType, self.mediaId, self.mediaUrl, self.positionMS, self.timestampMS]
                    _ = try db.executeV1(sql: sql, values: values)
                }
            }
        } catch let err {
            handleError(caller: "MediaPlayState.update", error: err)
        }
        self.dump(location: "update")
    }
    
    public func delete() {
        do {
            if let db = self.findDB() {
                let sql = "DELETE FROM MediaState WHERE mediaType = ? AND mediaId = ?"
                let values = [self.mediaType, self.mediaId]
                _ = try db.executeV1(sql: sql, values: values)
            }
            self.clear()
        } catch let err {
            handleError(caller: "MediaPlayState.delete", error: err)
        }
        self.dump(location: "delete")
    }
    
    private func handleError(caller: String, error: Error) {
        print("ERROR at \(caller) \(error.localizedDescription)")
        do {
            if let db = self.findDB() {
                let sql1 = "SELECT count(*) FROM sqlite_master WHERE type='table' AND name = 'MediaState'"
                let resultSet: [[String?]] = try db.queryV1(sql: sql1, values: [])
                if (resultSet.count > 0) {
                    let row: [String?] = resultSet[0]
                    if let countStr = row[0] {
                        if let count = Int(countStr) {
                            if count < 1 {
                                let sql2 = "CREATE TABLE MediaState(" +
                                    " mediaType TEXT NOT NULL," +
                                    " mediaId TEXT NOT NULL," +
                                    " mediaUrl TEXT NOT NULL," +
                                    " position INT default 0," +
                                    " timestamp INT NOT NULL," +
                                    " PRIMARY KEY(mediaType, mediaId)," +
                                " CHECK (mediaType IN ('audio', 'video')))"
                                _ = try db.executeV1(sql: sql2, values: [])
                            }
                        }
                    }
                }
            }
        } catch let err {
            print("ERROR at MediaPlayState.handleError \(err.localizedDescription)")
        }
    }
    
    private func findDB() -> Sqlite3? {
        do {
            let db: Sqlite3 = try Sqlite3.findDB(dbname: "Settings.db")
            return db
        } catch let err {
            print("Error opening Settings.db \(err.localizedDescription)")
            return nil
        }
    }
}
