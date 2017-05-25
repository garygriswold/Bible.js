//
//  AwsS3UnitTest.swift
//  AWS_S3_Prototype
//
//  Created by Gary Griswold on 5/16/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation

public class AwsS3UnitTest {
	
	func testDriver() {
        //s3.testPresignedGET()
        s3.testUploadData()
        //s3.testDownloadData()
        //s3.testDownloadFile()
        //s3.testDownloadZipFile()
        //s3.testZipUnzip()
        //s3.testUploadFile()
    }
    
    func testPresignedGET() {
        let s3 = AwsS3()
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
        let s3 = AwsS3()
        let message = "Hello World"
        let data = message.data(using: String.Encoding.utf8)
        s3.uploadData(s3Bucket: "shortsands", s3Key: "hello1", data: data!, contentType: "text/plain",
                      complete: { err in print("I RECEIVED CALLBACK 1 \(String(describing: err))")})
        
        s3.uploadData(s3Bucket: "shortsands", s3Key: "hello1", data: data!, contentType: "text/plain",
                      complete: { err in print("I RECEIVED CALLBACK 2 \(String(describing: err))")})
        
        s3.uploadData(s3Bucket: "shortsands", s3Key: "hello1", data: data!, contentType: "text/plain",
                      complete: uploadDataHandler)
        
        s3.uploadText(s3Bucket: "shortsands", s3Key: "hello2", data: "Hello World Again",
                        complete: { err in print("I RECEIVED loadString CALLBACK \(String(describing: err))")})
        
        s3.uploadVideoAnalytics(sessionId: "12345", timestamp: "12345", data: "Hello World Third Time",
                           complete: { err in print("I RECEIVED loadAnalytics CALLBACK \(String(describing: err))")})
    }
    
    func uploadDataHandler(err: Error?) {
        print ("I RECEIVED CALLBACK 3 \(String(describing: err))")
    }
    
    func testDownloadData() {
        let s3 = AwsS3()
        s3.downloadText(s3Bucket: "shortsands", s3Key: "hello1",
                        complete: {error, data in print("DOWNLOADED err \(String(describing: error))  data \(data)")})
    }
    
    func testDownloadFile() {
        let s3 = AwsS3()
        s3.downloadFile(s3Bucket: "shortsands", s3Key: "WEB.db.zip", filePath: "/Documents/WEB.db.zip",
                        complete: { err in print("I RECEIVED testDownloadFile CALLBACK \(String(describing: err))")})
        
        s3.downloadFile(s3Bucket: "shortsands", s3Key: "hello2", filePath: "/Documents/hello2.txt",
                        complete: { err in print("I RECEIVED testDownloadFile CALLBACK \(String(describing: err))")})
    }
    
    func testDownloadZipFile() {
        let s3 = AwsS3()
//        s3.downloadZipFile(s3Bucket: "shortsands", s3Key: "WEB.db.zip", filePath: "/Documents/WEB.db",
//                           complete: { err in print("I RECEIVED testDownloadZipFile CALLBACK \(String(describing: err))")})
    }
    
    func testUploadFile() {
        let s3 = AwsS3()
        s3.uploadFile(s3Bucket: "shortsands", s3Key: "uploadFile1", filePath: "/Documents/MichaelMark.jpg",
                      contentType: "image/jpg",
                      complete: { err in print("RESULT testUploadFile CALLBACK Error: \(String(describing: err))")})
        
        s3.uploadFile(s3Bucket: "shortsands", s3Key: "uploadFile2", filePath: "/Documents/WEB.db.zip",
                      contentType: "application/zip",
                      complete: { err in print("RESULT testUploadFile CALLBACK Error: \(String(describing: err))")})
        
        s3.uploadFile(s3Bucket: "shortsands", s3Key: "uploadFile3", filePath: "/Documents/hello2.txt",
                      contentType: "plain/text",
                      complete: { err in print("RESULT testUploadFile CALLBACK Error: \(String(describing: err))")})
    }
    
    func testZipUnzip() {
        let s3 = AwsS3()
//        s3.zip(sourceFile: "/Documents/ZIPTEST.db", targetFile: "/Documents/ZIPTEST.db.zip")
//        s3.unzip(sourceFile: "/Documents/ZIPTEST.db.zip", targetFile: "/Documents/ZIPTEST_OUT.db")
        
        let done = s3.unzip(sourceFile: "/Documents/ZIPTEST2.db.zip", targetDir: "/tmp/")
        print("UNZIP /Documents/ZIPTEST2.db.zip is successful? \(done)")
    }
}
