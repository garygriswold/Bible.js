//
//  AwsS3Cache.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/9/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
// The read function will read cache and return it if present and unexpired, then it will access online
// And return the result, saving it in cache after it is returned.
//
//

public class AwsS3Cache {
    
    private static let DEBUG = true
    
    public static let shared = AwsS3Cache()
    
    let cacheDir: URL
    
    private init() {
        let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
        let libDir: URL = homeDir.appendingPathComponent("Library")
        self.cacheDir = libDir.appendingPathComponent("Caches")
    }
    
    deinit {
        print("***** Deinit AwsS3Cache *****")
    }
    
    /**
     * To force reading the data from AWS S3 use expireInterval 0.
     * To prevent expiration of data in Cache and only use AWS S3 if the file is not present use Double.infinity
     */
    public func readData(s3Bucket: String, s3Key: String, expireInterval: TimeInterval,
                         getComplete: @escaping (_ data: Data?) -> Void) {
        let startTime = Date()
        let path: URL = self.getPath(s3Bucket: s3Bucket, s3Key: s3Key)
        let data: Data? = self.readCache(path: path, expireInterval: expireInterval)
        if data != nil {
            reportTimeCompleted(start: startTime, success: true, inCache: true, path: path)
            getComplete(data)
        } else {
            AwsS3Manager.findDbp().downloadData(
                s3Bucket: s3Bucket,
                s3Key: s3Key,
                complete: { error, data in
                    if let err = error {
                        print("Error accessing S3 in MetaDataCache \(err)")
                        self.reportTimeCompleted(start: startTime, success: false, inCache: false, path: path)
                        getComplete(nil)
                    }
                    else {
                        self.reportTimeCompleted(start: startTime, success: true, inCache: false, path: path)
                        getComplete(data)
                        do {
                            try data?.write(to: path)
                        } catch( let writeErr ) {
                            print("Error while writing file in AWSS3Cache.readAWSS3 \(writeErr)")
                        }
                    }
                }
            )
        }
    }
    
    public func readFile(s3Bucket: String, s3Key: String, expireInterval: TimeInterval,
                         getComplete: @escaping (_ file: URL?) -> Void) {
        let startTime = Date()
        let path: URL = self.getPath(s3Bucket: s3Bucket, s3Key: s3Key)
        if FileManager.default.isReadableFile(atPath: path.path) {
            reportTimeCompleted(start: startTime, success: true, inCache: true, path: path)
            getComplete(path)
        } else {
            AwsS3Manager.findDbp().downloadFile(
                s3Bucket: s3Bucket,
                s3Key: s3Key,
                filePath: path,
                complete: { error in
                    if let err = error {
                        print("Error accessing S3 in MetaDataCache \(err)")
                        self.reportTimeCompleted(start: startTime, success: false, inCache: false, path: path)
                        getComplete(nil)
                    }
                    else {
                        self.reportTimeCompleted(start: startTime, success: true, inCache: false, path: path)
                        getComplete(path)
                    }
                }
            )
        }
    }
    
    public func hasFile(s3Bucket: String, s3Key: String) -> Bool {
        let path: URL = self.getPath(s3Bucket: s3Bucket, s3Key: s3Key)
        return FileManager.default.isReadableFile(atPath: path.path)
    }
    
    private func readCache(path: URL, expireInterval: TimeInterval) -> Data? {
        if (expireInterval >= 0) {
            print("Path to read \(path)")
            if FileManager.default.isReadableFile(atPath: path.path) {
                if (self.isFileExpired(filePath: path, expireInterval: expireInterval)) {
                    print("File has expired in AWSS3Cache.readCache")
                } else {
                    do {
                        let data = try Data(contentsOf: path, options: [])
                        return data
                    } catch let err {
                        print("Error occur in AWSS3Cache.readCache \(err)")
                    }
                }
            }
        }
        return nil
    }
    
    private func getPath(s3Bucket: String, s3Key: String) -> URL {
        let localKey = s3Key.replacingOccurrences(of: "/", with: "_")
        return self.cacheDir.appendingPathComponent(localKey)
    }
    
    private func isFileExpired(filePath: URL, expireInterval: TimeInterval) -> Bool {
        if (expireInterval >= Double.greatestFiniteMagnitude) {
            return false
        } else {
            do {
                let dictionary = try FileManager.default.attributesOfItem(atPath: filePath.path)
                let modifyDate = dictionary[FileAttributeKey.modificationDate] as? Date
                if let modDate = modifyDate {
                    print("modifyDate \(modDate)")
                    let interval = abs(modDate.timeIntervalSinceNow)
                    return interval > expireInterval
                } else {
                    return true
                }
            } catch let err {
                print("Error getting modification date \(err) ON FILE \(filePath)")
                return true
            }
        }
    }
    
    private func reportTimeCompleted(start: Date, success: Bool, inCache: Bool, path: URL) {
        if AwsS3Cache.DEBUG {
            let duration: TimeInterval? = start.timeIntervalSinceNow
            if let dur = duration {
                let howLong = round(dur * -1000)
                print("##### Cache Duration: \(howLong)  isCached: \(inCache)  Success: \(success)  Path: \(path.path)")
            } else {
                print("##### Cache Duration Failed")
            }
        }
    }
}

