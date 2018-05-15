//
//  AwsS3Manager.swift
//  AWS
//
//  Created by Gary Griswold on 4/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import AWSCore
#if USE_FRAMEWORK
import Utility
#endif

public class AwsS3Manager {
    
    private static var instance: AwsS3Manager?
    public static func getSingleton() -> AwsS3Manager {
        if (AwsS3Manager.instance == nil) {
            AwsS3Manager.instance = AwsS3Manager()
            AwsS3Manager.instance!.initialize()
        }
        return AwsS3Manager.instance!
    }
    
    public static func findSS() -> AwsS3 {
        let manager = getSingleton()
        return manager.findFor(region: manager.ssRegion)
    }
    public static func findDbp() -> AwsS3 {
        let manager = getSingleton()
        return manager.findFor(region: manager.dbpRegion)
    }
    public static func findTest() -> AwsS3 {
        let manager = getSingleton()
        return manager.findFor(region: manager.testRegion)
    }

    private let countryCode: String
    private var ssRegion: AwsS3Region
    private var dbpRegion: AwsS3Region
    private var testRegion: AwsS3Region
    private var awsS3Map: [AWSRegionType: AwsS3]
    
    private init() {
        if let country: String = Locale.current.regionCode {
            print("Country Code \(country)")
            self.countryCode = country
        } else {
            self.countryCode = "US"
        }
        // Set defaults to a valid region in case that initialize region fails.
        self.ssRegion = AwsS3Region(type: AWSRegionType.USEast1, name: "us-east-1")
        self.dbpRegion = AwsS3Region(type: AWSRegionType.USEast1, name: "us-east-1")
        self.testRegion = AwsS3Region(type: AWSRegionType.USWest2, name: "us-west-2")
        self.awsS3Map = [AWSRegionType: AwsS3]()
    }
    private func initialize() {
        let db = Sqlite3()
        let sql = "SELECT awsRegion FROM Region WHERE countryCode=?"
        do {
            try db.open(dbname: "Versions.db", copyIfAbsent: true)
            defer { db.close() }
            let resultSet = try db.queryV1(sql: sql, values: [self.countryCode])
            if resultSet.count > 0 {
                let row = resultSet[0]
                if let awsRegion = row[0] {
                    self.ssRegion = AwsS3Manager.getRegionType(region: awsRegion)
                }
                // The following is here as a reminder that we should pull this from the Region table.
                self.dbpRegion = AwsS3Manager.getRegionType(region: "us-east-1")
            }
        } catch let err {
            print("Unable to set regions \(Sqlite3.errorDescription(error: err))")
        }
    }
    static func getRegionType(region: String) -> AwsS3Region {
        let regionType = region.aws_regionTypeValue()
        if (regionType == AWSRegionType.Unknown) {
            return AwsS3Region(type: AWSRegionType.USEast1, name: "us-east-1")
        } else {
            return AwsS3Region(type: regionType, name: region)
        }
    }
    deinit {
        print("****** Deinitialize AwsS3Manager ******")
    }
    private func findFor(region: AwsS3Region) -> AwsS3 {
        var awsS3 = self.awsS3Map[region.type]
        if (awsS3 == nil) {
            awsS3 = AwsS3(region: region)
            self.awsS3Map[region.type] = awsS3
        }
        return(awsS3!)
    }
}
