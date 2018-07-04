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
   
    public let current: MediaPlayState
    private let database: Sqlite3?
    
    public init(mediaType: String) {
        self.current = MediaPlayState(mediaType: mediaType)
        do {
            self.database = try Sqlite3.findDB(dbname: "Settings.db")
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
            self.current.clear(mediaId: mediaId)
            if let db = self.database {
                let sql = "SELECT mediaUrl, position, timestamp" +
                " FROM MediaState WHERE mediaType = ? AND mediaId = ?"
                let resultSet: [[String?]] = try db.queryV1(sql: sql, values: self.current.getKey())
                if (resultSet.count > 0) {
                    let row = resultSet[0];
                    self.current.mediaUrl = row[0] ?? "unknown"
                    self.current.positionMS = Int64(row[1] ?? "0") ?? 0
                    self.current.timestampMS = Int64(row[2] ?? "0") ?? MediaPlayState.now()
                }
            }
        } catch let err {
            handleError(caller: "MediaPlayStateIO.retrieve", error: err)
        }
        self.current.dump()
        return self.current
    }
    
    public func update(position: CMTime) {
        update(mediaUrl: current.mediaUrl, position: position)
    }
    
    public func update(mediaUrl: String, position: CMTime) {
        do {
            self.current.dump()
            self.current.update(mediaUrl: mediaUrl, position: position)
            self.current.dump()
            if let db = self.database {
                let sql = "REPLACE INTO MediaState(mediaType, mediaId, mediaUrl, position, timestamp)" +
                " VALUES (?, ?, ?, ?, ?)"
                print("FIELDS \(self.current.getDBFields())")
                _ = try db.executeV1(sql: sql, values: self.current.getDBFields())
            }
        } catch let err {
            handleError(caller: "MediaPlayStateIO.update", error: err)
        }
    }
    
    public func clear() {
        do {
            if let db = self.database {
                let sql = "DELETE FROM MediaState WHERE mediaType = ? AND mediaId = ?"
                _ = try db.executeV1(sql: sql, values: self.current.getKey())
            }
            self.current.clear()
        } catch let err {
            handleError(caller: "MediaPlayStateIO.clear", error: err)
        }
    }
    
    private func handleError(caller: String, error: Error) {
        print("ERROR at \(caller) \(error.localizedDescription)")
        do {
            if let db = self.database {
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
            print("ERROR at MediaPlayStateIO.handleError \(err.localizedDescription)")
        }
    }
}
