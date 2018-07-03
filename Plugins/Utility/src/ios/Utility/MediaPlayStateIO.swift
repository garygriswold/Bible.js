//
//  MediaPlayStateIO.swift
//  Utility
//
//  Created by Gary Griswold on 7/3/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import CoreMedia

public class MediaPlayStateIO {
   
    public let currentState: MediaPlayState
    private let database: Sqlite3?
    
    public init(mediaType: String) {
        self.currentState = MediaPlayState(mediaType: mediaType)
        do {
            self.database = try Sqlite3.openDB(dbname: "Settings.db", copyIfAbsent: false)
        } catch let err {
            print("Error opening Settings.db \(err.localizedDescription)")
            self.database = nil
        }
    }
    
    deinit {
        print("****** deinit MediaPlayStateIO ******")
    }
    
    public func retrieve(mediaId: String) -> MediaPlayState {
        do {
            self.currentState.clear(mediaId: mediaId)
            if let db = self.database {
                let sql = "SELECT mediaUrl, position, timestamp" +
                " FROM MediaPlayState WHERE mediaType = ? AND mediaId = ?";
                let resultSet: [Dictionary<String,Any?>] = try db.queryV0(sql: sql,
                                                                          values: self.currentState.getKey())
                if (resultSet.count > 0) {
                    let row = resultSet[0];
                    self.currentState.mediaUrl = row["mediaUrl"] as? String ?? "unknown"
                    self.currentState.positionMS = row["position"] as? Int64 ?? 0
                    self.currentState.timestampMS = row["timesamp"] as? Int64 ?? 0
                }
            }
        } catch let err {
            handleError(caller: "MediaPlayStateIO.retrieve", error: err)
        }
        return self.currentState
    }
    
    public func update(position: CMTime) {
        update(mediaUrl: currentState.mediaUrl, position: position)
    }
    
    public func update(mediaUrl: String, position: CMTime) {
        do {
            self.currentState.update(mediaUrl: mediaUrl, position: position)
            if let db = self.database {
                let sql = "REPLACE INTO MediaPlayState(mediaType, mediaId, mediaUrl, position, timestamp)" +
                " VALUES (?, ?, ?, ?, ?);"
                _ = try db.executeV1(sql: sql, values: self.currentState.getDBFields())
            }
        } catch let err {
            handleError(caller: "MediaPlayStateIO.update", error: err)
        }
    }
    
    public func clear() {
        do {
            if let db = self.database {
                let sql = "DELETE FROM MediaPlayState WHERE mediaType = ? AND mediaId = ?"
                _ = try db.executeV1(sql: sql, values: self.currentState.getKey())
            }
            self.currentState.clear()
        } catch let err {
            handleError(caller: "MediaPlayStateIO.clear", error: err)
        }
    }
    
    private func handleError(caller: String, error: Error) {
        print("ERROR at \(caller) \(error.localizedDescription)")
        do {
            if let db = self.database {
                let sql = "CREATE TABLE MediaPlayState(" +
                    " mediaType TEXT NOT NULL," +
                    " mediaId TEXT NOT NULL," +
                    " mediaUrl TEXT NOT NULL," +
                    " position INT default 0," +
                    " timestamp INT NOT NULL," +
                    " PRIMARY KEY(mediaType, mediaId)," +
                    " CHECK (mediaType IN ('audio', 'video'))"
                _ = try db.executeV1(sql: sql, values: [])
            }
        } catch let err {
            print("ERROR at MediaPlayStateIO.handleError \(err.localizedDescription)")
        }
        self.currentState.clear()
    }
}
