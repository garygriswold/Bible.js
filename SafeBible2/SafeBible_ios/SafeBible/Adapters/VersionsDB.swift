//
//  VersionsDB.swift
//  Settings
//
//  Created by Gary Griswold on 10/24/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Utility

struct VersionsDB {
    
    static var shared = VersionsDB()
    
    private init() {}
    
    //
    // Bible
    //
    func getBible(bibleId: String) -> Bible {
        let sql = "SELECT bibleId, abbr, iso3, localizedName, textBucket, textId, keyTemplate,"
            + " audioBucket, otDamId, ntDamId FROM Bible WHERE bibleId = ?"
        do {
            let db: Sqlite3 = try self.getVersionsDB()
            let resultSet: [[String?]] = try db.queryV1(sql: sql, values: [bibleId])
            if resultSet.count > 0 && resultSet[0].count > 0 {
                let row = resultSet[0]
                return Bible(bibleId: row[0]!, abbr: row[1]!, iso3: row[2]!, name: row[3]!,
                             textBucket: row[4]!, textId: row[5]!, s3TextTemplate: row[6]!,
                             audioBucket: row[7]!, otDamId: row[8]!, ntDamId: row[9]!,
                             locale: Locale.current)
            }
        } catch let err {
            print("ERROR: SettingsDB.getSettings \(err)")
        }
        // Return default, because optional causes too many complexities in program
        // Failure could occur when a bibleId in user history is removed.
        return Bible(bibleId: "ENGESV", abbr: "ESV", iso3: "eng", name: "English Standard",
                     textBucket: "dbp-prod", textId: "ENGESV", s3TextTemplate: "%I_%O_%B_%C.html",
                     audioBucket: nil, otDamId: nil, ntDamId: nil, locale: Locale.current)
    }
    
    //
    // Videos
    //
    func getJesusFilmLanguage(iso3: String, country: String?) -> String {
//        var that = this;
//        var statement = 'SELECT languageId FROM JesusFilm WHERE countryCode=? AND silCode=? ORDER BY population DESC';
//        this.database.select(statement, [ countryCode, silCode ], function(results) {
//            if (results instanceof IOError) {
//                console.log('SQL Error in selectJesusFilmLanguage, query 1', results);
//                callback({});
//            } else if (results.rows.length > 0) {
//                callback(results.rows.item(0));
//            } else {
//                statement = 'SELECT languageId FROM JesusFilm WHERE silCode=? ORDER BY population DESC';
//                that.database.select(statement, [ silCode ], function(results) {
//                    if (results instanceof IOError) {
//                        console.log('SQL Error in selectJesusFilmLanguage, query 2', results);
//                        callback({});
//                    } else if (results.rows.length > 0) {
//                        callback(results.rows.item(0));
//                    } else {
//                        callback({});
//                    }
//                });
//            }
//        });
//        return ""
    }
    
    func getVideos(iso3: String, languageId: String) -> [Video] {
//        var that = this;
//        var selectList = 'SELECT languageId, mediaId, silCode, langCode, title, lengthMS, HLS_URL,' +
//        ' (longDescription is not NULL) AS hasDescription FROM Video';
//        var statement = selectList + ' WHERE languageId IN (?,?)';
//        this.database.select(statement, [ languageId, silCode ], function(results) {
//            if (results instanceof IOError) {
//                console.log('found Error', results);
//                callback({});
//            } else {
//                if (results.rows.length > 0) {
//                    returnVideoMap(languageId, silCode, results, callback);
//                } else {
//                    statement = selectList + ' WHERE langCode IN (?,?)';
//                    that.database.select(statement, [langCode, langPrefCode], function(results) {
//                        if (results instanceof IOError) {
//                            callback({});
//                        } else {
//                            if (results.rows.length > 0) {
//                                returnVideoMap(languageId, silCode, results, callback);
//                            } else {
//                                statement = selectList + ' WHERE langCode = "en"';
//                                that.database.select(statement, [], function(results) {
//                                    if (results instanceof IOError) {
//                                        callback({});
//                                    } else {
//                                        returnVideoMap(languageId, silCode, results, callback);
//                                    }
//                                });
//                            }
//                        }
//                    });
//                }
//            }
//        });
//
//        function returnVideoMap(languageId, silCode, results, callback) {
//            var videoMap = {};
//            for (var i=0; i<results.rows.length; i++) {
//                var row = results.rows.item(i);
//                var meta = new VideoMetaData();
//                meta.mediaSource = (row.mediaId.indexOf("KOG") > -1) ? "Rock" : "JFP";
//                meta.languageId = languageId;
//                meta.silCode = silCode;
//                meta.langCode = row.langCode;
//                meta.mediaId = row.mediaId;
//                meta.title = row.title;
//                meta.lengthInMilliseconds = row.lengthMS;
//                meta.hasDescription = row.hasDescription;
//                meta.mediaURL = row.HLS_URL;
//                videoMap[row.mediaId] = meta;
//            }
//            callback(videoMap);
//        }
        
    }
    
    func selectDescription = function(languageId, silCode, mediaId, callback) -> String {
//        var that = this;
//        var statement = "SELECT longDescription FROM Video WHERE (languageId = ? OR silCode = ?) AND mediaID = ?";
//        this.database.selectHTML(statement, [languageId, silCode, mediaId], function(results) {
//        if (results instanceof IOError) {
//        callback("");
//        } else {
//        callback(results);
//        }
//        });
    }
    
    //
    // Common
    //
    private func getVersionsDB() throws -> Sqlite3 {
        var db: Sqlite3?
        let dbname = "Versions.db"
        do {
            db = try Sqlite3.findDB(dbname: dbname)
        } catch Sqlite3Error.databaseNotOpenError {
            db = try Sqlite3.openDB(dbname: dbname, copyIfAbsent: true)
        }
        return db!
    }
}

