//
//  AwsS3UnitTest2.swift
//  AWS_Testharness
//
//  Created by Gary Griswold on 4/6/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import AWSCore
import AWS

public class AwsS3UnitTest2 {
    
    func testDriver() {
        AwsS3.region = "us-west-2"
        //testPresignedGET()
        //testUploadData()
        //testDownloadData()
        //testDownloadFile()
        testUnzipFile()
        //testDownloadZipFile()
        //testZipUnzip()
        //testUploadFile()
    }
    
    func testPresignedGET() {
        let s3 = AwsS3.shared
        s3.preSignedUrlGET(s3Bucket: "shortsands", s3Key: "KJVPD.db.zip", expires: 3600,
                           complete: {
                            url in print("computed GET URL \(String(describing: url))")
                            let request = URLRequest(url: url!)
                            let downloadTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: request)
                            downloadTask.resume()
        })
        
        s3.preSignedUrlPUT(s3Bucket: "shortsands", s3Key: "signedPUT1", expires: 3600, contentType: "text/plain",
                           complete: {
                            url in print("computed PUT URL \(String(describing: url))")
                            var request = URLRequest(url: url!)
                            request.cachePolicy = .reloadIgnoringLocalCacheData
                            request.httpMethod = "PUT"
                            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
                            
                            let uploadTask: URLSessionTask = URLSession.shared.uploadTask(with: request, fromFile: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/hello1.txt"))
                            uploadTask.resume()
                            
        })
    }
    
    func testUploadData() {
        let s3 = AwsS3.shared
        let message = "Hello World"
        let data = message.data(using: String.Encoding.utf8)
        s3.uploadData(s3Bucket: "shortsands", s3Key: "hello1", data: data!, contentType: "text/plain",
                      complete: { err in print("I RECEIVED CALLBACK 1 \(String(describing: err))")})
        
        s3.uploadData(s3Bucket: "shortsands", s3Key: "hello1", data: data!, contentType: "text/plain",
                      complete: { err in print("I RECEIVED CALLBACK 2 \(String(describing: err))")})
        
        s3.uploadData(s3Bucket: "shortsands", s3Key: "hello1", data: data!, contentType: "text/plain",
                      complete: uploadDataHandler)
        
        s3.uploadText(s3Bucket: "shortsands", s3Key: "hello2", data: "Hello World Again", contentType: "text/plain",
                      complete: { err in print("I RECEIVED loadString CALLBACK \(String(describing: err))")})
        var dict = [String: String]()
        dict["one"] = "two"
        s3.uploadAnalytics(sessionId: "12345", timestamp: "12345", prefix: "HelloV1", dictionary: dict,
                           complete: { err in print("I RECEIVED loadAnalytics CALLBACK \(String(describing: err))")})
    }
    
    func uploadDataHandler(err: Error?) {
        print ("I RECEIVED CALLBACK 3 \(String(describing: err))")
    }
    
    func testDownloadData() {
        let s3 = AwsS3.shared
        s3.downloadText(s3Bucket: "shortsands", s3Key: "hello1",
                        complete: {error, data in print("DOWNLOADED err \(String(describing: error))  data \(String(describing: data))")})
    }
    
    func testDownloadFile() {
        let s3 = AwsS3.shared
        let timer = Timer(place: "Start Download")
        let filePath1 = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/WEB.db")
        s3.downloadFile(s3Bucket: "shortsands", s3Key: "WEB.db", filePath: filePath1,
                        complete: { err in print("I RECEIVED testDownloadFile CALLBACK \(String(describing: err))")
                            timer.duration(place: "END Download")
        })
        /*
         let filePath2 = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/hello2.txt")
         s3.downloadFile(s3Bucket: "shortsands", s3Key: "hello2", filePath: filePath2,
         complete: { err in print("I RECEIVED testDownloadFile CALLBACK \(String(describing: err))")})
         */
    }
    
    func testUnzipFile() {
        let timer = Timer(place: "Start Unzip WEB.db.zip")
        let filePath = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/WEB.db.zip")
        let target = URL(fileURLWithPath: NSHomeDirectory() + "/Documents")
        do {
            try Zip.unzipFile(filePath, destination: target, overwrite: true, password: nil, progress: nil,
                fileOutputHandler: { unzippedFile in
                print("Unzipped file \(unzippedFile)")
                timer.duration(place: "END Unzip")
            })
        } catch let err {
            print("Caught Zip Error \(err)")
        }
    }
    /*
     func testDownloadZipFile() {
     let s3 = AwsS3.shared
     let filePath1 = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/WEB.db")
     s3.downloadZipFile(s3Bucket: "shortsands", s3Key: "WEB.db.zip", filePath: filePath1,
     complete: { err in print("I RECEIVED testDownloadZipFile CALLBACK \(String(describing: err))")})
     }
     */
    func testUploadFile() {
        let s3 = AwsS3.shared
        let filePath1 = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/MichaelMark.jpg")
        s3.uploadFile(s3Bucket: "shortsands", s3Key: "uploadFile1", filePath: filePath1,
                      contentType: "image/jpg",
                      complete: { err in print("RESULT testUploadFile CALLBACK Error: \(String(describing: err))")})
        
        let filePath2 = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/WEB.db.zip")
        s3.uploadFile(s3Bucket: "shortsands", s3Key: "uploadFile2", filePath: filePath2,
                      contentType: "application/zip",
                      complete: { err in print("RESULT testUploadFile CALLBACK Error: \(String(describing: err))")})
        
        let filePath3 = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/hello2.txt")
        s3.uploadFile(s3Bucket: "shortsands", s3Key: "uploadFile3", filePath: filePath3,
                      contentType: "plain/text",
                      complete: { err in print("RESULT testUploadFile CALLBACK Error: \(String(describing: err))")})
    }
    
    func testZipUnzip() {
        //        let s3 = AwsS3.shared
        //        s3.zip(sourceFile: "/Documents/ZIPTEST.db", targetFile: "/Documents/ZIPTEST.db.zip")
        //        s3.unzip(sourceFile: "/Documents/ZIPTEST.db.zip", targetFile: "/Documents/ZIPTEST_OUT.db")
        
        //        let done = s3.unzip(sourceFile: "/Documents/ZIPTEST2.db.zip", targetDir: "/tmp/")
        //        print("UNZIP /Documents/ZIPTEST2.db.zip is successful? \(done)")
    }
}

