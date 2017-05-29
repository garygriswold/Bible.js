//
//  AwsS3.swift
//  AWS_S3_Prototype
//
//  Created by Gary Griswold on 5/15/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
//import AWSS3

public class AwsS3 {
    
    static let VIDEO_ANALYTICS_BUCKET = "video.analytics.shortsands"
    
    private var transfer: AWSS3TransferUtility
    
    init() {
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest2,
                                                    credentialsProvider: Credentials.AWS_BIBLE_APP)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        //AWSS3TransferUtility.interceptApplication was not set, because we do not need it.
        self.transfer = AWSS3TransferUtility.default()
    }
    /**
    * A Unit Test Method
    */
    func echo3(message: String) -> String {
	    return message;
    }
    /////////////////////////////////////////////////////////////////////////
    // URL signing Functions
    /////////////////////////////////////////////////////////////////////////
    /**
    * This method produces a presigned URL for a GET from an AWS S3 bucket
    */
    func preSignedUrlGET(s3Bucket: String, s3Key: String, expires: Int,
                         complete: @escaping (_ url:URL?) -> Void) {
        let request = AWSS3GetPreSignedURLRequest()
        request.httpMethod = AWSHTTPMethod.GET
        request.bucket = s3Bucket
        request.key = s3Key
        request.expires = Date(timeIntervalSinceNow: TimeInterval(expires))
        presignURL(request: request, complete: complete)
    }
    /**
    * This method produces a presigned URL for a PUT to an AWS S3 bucket
    */
    func preSignedUrlPUT(s3Bucket: String, s3Key: String, expires: Int, contentType: String,
                         complete: @escaping (_ url:URL?) -> Void) {
        let request = AWSS3GetPreSignedURLRequest()
        request.httpMethod = AWSHTTPMethod.PUT
        request.bucket = s3Bucket
        request.key = s3Key
        request.expires = Date(timeIntervalSinceNow: TimeInterval(expires))
        request.contentType = contentType
        presignURL(request: request, complete: complete)
    }
    /**
    * This private method is the actual preSignedURL call
    */
    private func presignURL(request: AWSS3GetPreSignedURLRequest,
                            complete: @escaping (_ url:URL?) -> Void) {
        let builder = AWSS3PreSignedURLBuilder.default()
        builder.getPreSignedURL(request).continueWith { (task) -> URL? in
            if let error = task.error {
                print("Error: \(error)")
                complete(nil)
            } else {
                let presignedURL = task.result!
                complete(presignedURL as URL)
            }
            return nil
        }
    }
    /////////////////////////////////////////////////////////////////////////
    // Zip Functions
    /////////////////////////////////////////////////////////////////////////
    /**
     * Zip Utility for use on files.
     */
    func zip(sourceFile: String, targetDir: String) -> Bool {
        //let done = SSZipArchive.createZipFile(atPath: sourceFile, withContentsOfDirectory: targetDir)
        //(BOOL)createZipFileAtPath:(NSString *)path withContentsOfDirectory:(NSString *)directoryPath;
        let done = false
        return done
    }
    /**
     * UnZip Utility for use on files.
     */
    func unzip(sourceFile: String, targetDir: String) -> Bool {
        //let done = SSZipArchive.unzipFile(atPath: sourceFile, toDestination: targetDir)
        //print("DID unzip \(done)")
        let done = false
        return done
    }
    /////////////////////////////////////////////////////////////////////////
    // Download Functions
    /////////////////////////////////////////////////////////////////////////
    /**
    * Download Text to String object
    */
    func downloadText(s3Bucket: String, s3Key: String,
                      complete: @escaping (_ error:Error?, _ data:String?) -> Void) {
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {(task, url, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.downloadText \(s3Bucket) \(s3Key) Error: \(err)")
                } else {
                    print("SUCCESS in s3.downloadText \(s3Bucket) \(s3Key)")
                }
                let datastring = (data != nil) ? String(data: data!, encoding: String.Encoding.utf8) as String? : ""
                complete(error, datastring)
            })
        }
        download(s3Bucket: s3Bucket, s3Key: s3Key, completionHandler: completionHandler)
    }
    /**
    * Download Binary object to Data, receiving code might need to convert it needed form
    */
    func downloadData(s3Bucket: String, s3Key: String,
                      complete: @escaping (_ error:Error?, _ data:Data?) -> Void) {
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {(task, url, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.downloadData \(s3Bucket) \(s3Key) Error: \(err)")
                } else {
                    print("SUCCESS in s3.downloadData \(s3Bucket) \(s3Key)")
                }
                complete(error, data)
            })
        }
        download(s3Bucket: s3Bucket, s3Key: s3Key, completionHandler: completionHandler)
    } 
    /**
    * Download File.  This works for binary and text files. This method does not use
    * TransferUtility.fileDownload, because it is unable to provide accurate errors
    * when the file IO fails.
    */
    func downloadFile(s3Bucket: String, s3Key: String, filePath: URL,
                      complete: @escaping (_ error:Error?) -> Void) {
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {(task, url, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.downloadFile \(s3Bucket) \(s3Key) Error: \(err)")
                    complete(error)
                } else {
                    do {
                        try data?.write(to: filePath, options: Data.WritingOptions.atomic)
                        print("SUCCESS in s3.downloadFile \(s3Bucket) \(s3Key)")
                        complete(nil)
                    } catch {
                        print("File IO Error in s3.downloadFile \(s3Bucket) \(s3Key)")
                        complete(nil) // pass error here, if I knew how to catch or create one.
                    }
                }
            })
        }
        download(s3Bucket: s3Bucket, s3Key: s3Key, completionHandler: completionHandler)
    }   
    /**
    * Download zip file and unzip it.  Like Download File this does not use 
    * TransferUtility.fileDownload because its error reporting is poor.
    *
    * NOTE: This is NOT working for files that were zipped using MacOs version of PKzip
    * and so it should be be used in the App.!!!!! May 19, 2017 GNG
    */
    func downloadZipFile(s3Bucket: String, s3Key: String, filePath: URL,
                         complete: @escaping (_ error:Error?) -> Void) {
	    downloadFile(s3Bucket: s3Bucket, s3Key: s3Key, filePath: filePath, complete: complete)
	    /*                     
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {(task, url, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.downloadZipFile \(s3Bucket) \(s3Key) Error: \(err)")
                    complete(error)
                } else if (data != nil) {
                    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "/" + NSUUID().uuidString)
                    do {
                        try data!.write(to: tempURL, options: Data.WritingOptions.atomic)
                        let unzipped = self.unzip(sourceFile: tempURL.absoluteString,
                                                  targetDir: tempURL.absoluteString)
                        print("Unzip succeeded? \(unzipped)")
                        // locate file in the tempURL directory
                        // move the file to filePath
                        let destUrl = URL(fileURLWithPath: NSHomeDirectory() + filePath)
                        let fileManager = FileManager.default
                        try fileManager.moveItem(at: tempURL, to: destUrl)
                        print("SUCCESS in s3.downloadZipFile \(s3Bucket) \(s3Key)")
                        complete(nil)
                    } catch {
                        print("File IO Error in s3.downloadZipFile \(s3Bucket) \(s3Key)")
                        complete(nil) // pass error here, if I knew how to catch or create one.
                    }
                } else {
                    print("NO ERROR in s3.downloadZipFile and NO DATA \(s3Bucket) \(s3Key)") // add error if poss
                    complete(nil)
                }
            })
        }
        download(s3Bucket: s3Bucket, s3Key: s3Key, completionHandler: completionHandler)
        */
    }
    /**
    * Internal getObject method
    */
    private func download(s3Bucket: String, s3Key: String,
                          completionHandler: @escaping AWSS3TransferUtilityDownloadCompletionHandlerBlock) {
        self.transfer.downloadData(
            fromBucket: s3Bucket,
            key: s3Key,
            expression: nil,
            completionHandler: completionHandler)
        //.continueWith has been dropped, because it did not report errors
    }
    /////////////////////////////////////////////////////////////////////////
    // Upload Functions
    /////////////////////////////////////////////////////////////////////////
    /**
    * Upload Analytics in Text form, such as JSON to analytics bucket
    */
    func uploadVideoAnalytics(sessionId: String, timestamp: String, data: String,
                         complete: @escaping (_ error: Error?) -> Void) {
        let s3Key = sessionId + timestamp
        let textData = data.data(using: String.Encoding.utf8)
        uploadData(s3Bucket: AwsS3.VIDEO_ANALYTICS_BUCKET, s3Key: s3Key, data: textData!, contentType: "text/plain",
                    complete: complete)
    }
    /**
    * Upload string object to bucket
    */
    func uploadText(s3Bucket: String, s3Key: String, data: String,
                      complete: @escaping (_ error: Error?) -> Void) {
        let textData = data.data(using: String.Encoding.utf8)
        uploadData(s3Bucket: s3Bucket, s3Key: s3Key, data: textData!, contentType: "text/plain", complete: complete)
    }
    /**
     * Upload object in Data form to bucket.  Data must be prepared to correct form
     * before calling this function.
     */
    func uploadData(s3Bucket: String, s3Key: String, data: Data, contentType: String,
                    complete: @escaping (_ error: Error?) -> Void) {
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = {(task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.uploadData \(s3Bucket) \(s3Key) Error: \(err)")
                } else {
                    print("SUCCESS in s3.uploadData \(s3Bucket) \(s3Key)")
                }
                complete(error)
            })
        }
        self.transfer.uploadData(data,
                            bucket: s3Bucket,
                            key: s3Key,
                            contentType: contentType,
                            expression: nil,
                            completionHandler: completionHandler)
        //.continueWith has been dropped, because it did not report errors
    }
    /**
    * Upload file to bucket, this works for text or binary files
    */
    func uploadFile(s3Bucket: String, s3Key: String, filePath: URL, contentType: String,
                    complete: @escaping (_ error: Error?) -> Void) {
        do {
            // Uncertain what .uncached means and if entry is best choice.
            let data = try Data(contentsOf: filePath, options: Data.ReadingOptions.uncached)
            uploadData(s3Bucket: s3Bucket, s3Key: s3Key, data: data, contentType: contentType,
                       complete: complete)
        } catch {
            // Can I capture error here, and use it in message and complete
            print("ERROR in s3.uploadFile, while reading file \(s3Bucket) \(s3Key)")
            complete(nil)
        }
    }
}
