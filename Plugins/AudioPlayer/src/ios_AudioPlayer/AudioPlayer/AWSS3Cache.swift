//
//  AWSS3Cache.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/9/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AWS

class AWSS3Cache {
    
    let cacheDir: URL
    let expirationInterval: TimeInterval
    
    init() {
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        self.cacheDir = libDir.appendingPathComponent("Caches")
        self.expirationInterval = 604800 // 1 week in seconds
    }
    
    deinit {
        print("De-initialized AWSS3Cache")
    }
    
    func read(s3Bucket: String, s3Key: String, getComplete: @escaping (_ data: Data?) -> Void) {
        let localKey = self.getLocalKey(s3Bucket: s3Bucket, s3Key: s3Key)
        let path: URL = self.cacheDir.appendingPathComponent(localKey)
        let data: Data? = self.readCache(path: path)
        if data != nil {
            getComplete(data)
        } else {
            self.readAWSS3(s3Bucket: s3Bucket, s3Key: s3Key, filePath: path, getComplete: getComplete)
        }
    }
    
    private func readCache(path: URL) -> Data? {
        print("Path to read \(path)")
        do {
            let data = try Data(contentsOf: path, options: [])
            if (self.isFileExpired(filePath: path)) {
                print("File has expired in AWSS3Cache.readCache")
                return nil
            } else {
                return data
            }
        } catch( let err ) {
            print("Error occur in AWSS3Cache.readCache \(err)")
            return nil
        }
    }
    
    private func readAWSS3(s3Bucket: String, s3Key: String, filePath: URL,
                getComplete: @escaping (_ data: Data?) -> Void) {
        AwsS3.shared.downloadData(
            s3Bucket: s3Bucket,
            s3Key: s3Key,
            complete: { error, data in
                if let err = error {
                    print("Error accessing S3 in MetaDataCache \(err)")
                    getComplete(nil)
                }
                else {
                    getComplete(data)
                    do {
                        try data?.write(to: filePath)
                    } catch( let writeErr ) {
                        print("Error while writing file in AWSS3Cache.readAWSS3 \(writeErr)")
                    }
                }
            }
        )
    }

    private func getLocalKey(s3Bucket: String, s3Key: String) -> String {
        return(s3Bucket + "_" + s3Key)
    }
    
    private func isFileExpired(filePath: URL) -> Bool {
        do {
            let dictionary = try FileManager.default.attributesOfItem(atPath: filePath.path)
            let creationDate = dictionary[FileAttributeKey.modificationDate] as? Date
            if let creation = creationDate {
                print("creationDate \(creation)")
                let interval = abs(creation.timeIntervalSinceNow)
                print("interval \(interval)")
                print("result \(interval > self.expirationInterval)")
                return interval > self.expirationInterval
            } else {
                return true
            }
        } catch let err {
            print("Error getting creation date \(err) ON FILE \(filePath)")
            return true
        }
    }
}
