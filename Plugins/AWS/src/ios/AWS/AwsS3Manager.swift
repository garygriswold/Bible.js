//
//  AwsS3Manager.swift
//  AWS
//
//  Created by Gary Griswold on 4/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import AWSCore
import Utility

public class AwsS3Manager {
    
    private static var instance: AwsS3Manager?
    public static func getSingleton() -> AwsS3Manager {
        if (AwsS3Manager.instance == nil) {
            AwsS3Manager.instance = AwsS3Manager()
            AwsS3Manager.instance!.initialize()
        }
        return AwsS3Manager.instance!
    }
    /**
    * This AwsS3 instance is computed based upon the country of the user to be the closest
    * region to the user.
    */
    public static func findSS() -> AwsS3 {
        let manager = getSingleton()
        return manager.findFor(region: manager.ssRegion, credential: Credentials.AWS_BIBLE_APP)
    }
    /**
    * This AwsS3 instance is always us-east-1.  It is for Short Sands local buckets
    * such as user.feedback.safebible
    */
    public static func findUSEast1() -> AwsS3 {
        let manager = getSingleton()
        return manager.findFor(region: manager.usEast1, credential: Credentials.AWS_BIBLE_APP)
    }
    /**
    * This AwsS3 instance is for accessing FCBH and DBS buckets.
    */
    public static func findDbp() -> AwsS3 {
        let manager = getSingleton()
        return manager.findFor(region: manager.dbpRegion, credential: Credentials.DBP_BIBLE_APP)
    }
    public static func findTest() -> AwsS3 {
        let manager = getSingleton()
        return manager.findFor(region: manager.testRegion, credential: Credentials.AWS_BIBLE_APP)
    }

    private let countryCode: String
    private var ssRegion: AwsS3Region
    private var usEast1: AwsS3Region
    private var dbpRegion: AwsS3Region
    private var testRegion: AwsS3Region
    private var awsS3Map: [String: AwsS3]
    
    private init() {
        if let country: String = Locale.current.regionCode {
            print("Country Code \(country)")
            self.countryCode = country
        } else {
            self.countryCode = "US"
        }
        // Set defaults to a valid region in case that initialize region fails.
        self.ssRegion = AwsS3Region(type: AWSRegionType.USEast1, name: "us-east-1")
        self.usEast1 = AwsS3Region(type: AWSRegionType.USEast1, name: "us-east-1")
        self.dbpRegion = AwsS3Region(type: AWSRegionType.USEast1, name: "us-east-1")
        self.testRegion = AwsS3Region(type: AWSRegionType.USWest2, name: "us-west-2")

        self.awsS3Map = [String: AwsS3]()
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
    private func findFor(region: AwsS3Region, credential: Credentials) -> AwsS3 {
        let key = credential.name + region.name
        var awsS3 = self.awsS3Map[key]
        if (awsS3 == nil) {
            awsS3 = AwsS3(region: region, credential: credential)
            self.awsS3Map[key] = awsS3
        }
        return(awsS3!)
    }
}
