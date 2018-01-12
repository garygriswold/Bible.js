//
//  AwsS3.swift
//  AWS_S3_Prototype
//
//  Created by Gary Griswold on 5/15/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AWSCore
import Zip

public class AwsS3 {
    
    // AwsS3.regionName should be set early in an App
    public static var region: String = "us-east-1"
    
    // Do not instantiate AwsS3, use AwsS3.shared
    private static var instance: AwsS3?
    public static var shared: AwsS3 {
        get {
            if (AwsS3.instance == nil) {
                AwsS3.instance = AwsS3(region: AwsS3.region)
            }
            return AwsS3.instance!
        }
    }
    
    private let endpoint: AWSEndpoint
    private let transfer: AWSS3TransferUtility
    
    private init(region: String) {
        var regionType = region.aws_regionTypeValue()
        if (regionType == AWSRegionType.Unknown) {
            regionType = AWSRegionType.USEast1
        }
	    self.endpoint = AWSEndpoint(region: regionType, service: AWSServiceType.S3, useUnsafeURL: false)!
        let credentialProvider = Credentials.AWS_BIBLE_APP
        let configuration = AWSServiceConfiguration(region: regionType,
                                                    endpoint: endpoint,
                                                    credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        //AWSS3TransferUtility.interceptApplication was not set, because we do not need it.
        self.transfer = AWSS3TransferUtility.default()
    }
    /**
    * A Unit Test Method
    */
    public func echo3(message: String) -> String {
	    return message;
    }
    /////////////////////////////////////////////////////////////////////////
    // URL signing Functions
    /////////////////////////////////////////////////////////////////////////
    /**
    * This method produces a presigned URL for a GET from an AWS S3 bucket
    */
    public func preSignedUrlGET(s3Bucket: String, s3Key: String, expires: Int,
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
    public func preSignedUrlPUT(s3Bucket: String, s3Key: String, expires: Int, contentType: String,
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
    // Download Functions
    /////////////////////////////////////////////////////////////////////////
    /**
    * Download Text to String object
    */
    public func downloadText(s3Bucket: String, s3Key: String,
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
		self.transfer.downloadData(fromBucket: s3Bucket, key: s3Key, expression: nil, completionHandler: completionHandler)
    }
    /**
    * Download Binary object to Data, receiving code might need to convert it needed form
    */
    public func downloadData(s3Bucket: String, s3Key: String,
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
		self.transfer.downloadData(fromBucket: s3Bucket, key: s3Key, expression: nil, completionHandler: completionHandler)
    } 
    /**
    * Download File.  This works for binary and text files. This method does not use
    * TransferUtility.fileDownload, because it is unable to provide accurate errors
    * when the file IO fails.
    */
    public func downloadFile(s3Bucket: String, s3Key: String, filePath: URL,
                      complete: @escaping (_ error:Error?) -> Void) {
        
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {(task, url, data, error) in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.downloadFile \(s3Bucket) \(s3Key) Error: \(err)")
                } else {
                    print("SUCCESS in s3.downloadFile \(s3Bucket) \(s3Key)")
                }
                complete(error)
            })
        }
        self.transfer.download(to: filePath, bucket: s3Bucket, key: s3Key, expression: nil,
                                    completionHandler: completionHandler)
        //.continueWith has been dropped, because it did not report errors
    }   
    /**
    * Download zip file and unzip it.  Like Download File this does not use 
    * TransferUtility.fileDownload because its error reporting is poor.
    */
    public func downloadZipFile(s3Bucket: String, s3Key: String, filePath: URL,
                         complete: @escaping (_ error:Error?) -> Void) {
 
        let temporaryDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        print("Temp Zip File Directory \(temporaryDirectory.absoluteString)")
        
        // Identify temp file for zip file download
        let tempZipURL = temporaryDirectory.appendingPathComponent(NSUUID().uuidString + ".zip")
        print("temp URL to store file \(tempZipURL.absoluteString)")
        
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {(task, url, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.downloadZipFile \(s3Bucket) \(s3Key) Error: \(err)")
                    complete(err)
                } else {
                    print("Download SUCCESS in s3.downloadZipFile \(s3Bucket) \(s3Key)")
                    do {
                        // unzip zip file
                        try Zip.unzipFile(tempZipURL,
                            destination: temporaryDirectory,
                            overwrite: true,
                            password: nil,
                            progress: nil
                        )
                        
                        // identify the unzipped file
						let filename = filePath.lastPathComponent
                        let unzippedURL = temporaryDirectory.appendingPathComponent(filename)
						print("location of unzipped file \(unzippedURL)")
						
						// remove unzipped file if it already exists
                        self.removeItemNoThrow(at: filePath)
			
						// move unzipped file to destination
                        try FileManager.default.moveItem(at: unzippedURL, to: filePath)
                        print("SUCCESS in s3.downloadZipFile \(s3Bucket) \(s3Key)")
                        complete(nil)
                    } catch let cotError {
	                    print("ERROR in s3.downloadZipFile \(s3Bucket) \(s3Key) Error: \(cotError)")
                        complete(cotError)
                    }
                    self.removeItemNoThrow(at: tempZipURL)
                }
            })
        }
        self.transfer.download(to: tempZipURL, bucket: s3Bucket, key: s3Key, expression: nil,
                               completionHandler: completionHandler)
        //.continueWith has been dropped, because it did not report errors
    }
    private func removeItemNoThrow(at: URL) -> Void {
        do {
            try FileManager.default.removeItem(at: at)
        } catch let error {
            print("Deleteion of \(at) Failed \(error.localizedDescription)")
        }
    }
    /////////////////////////////////////////////////////////////////////////
    // Upload Functions
    /////////////////////////////////////////////////////////////////////////
    /**
    * Upload Analytics from a Dictionary, that is converted to JSON.
    */
    public func uploadAnalytics(sessionId: String, timestamp: String, prefix: String, dictionary: [String: String],
                         complete: @escaping (_ error: Error?) -> Void) {
        var message: Data
        do {
            message = try JSONSerialization.data(withJSONObject: dictionary,
                                                 options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let jsonError {
            print("ERROR while converting message to JSON \(jsonError)")
            let errorMessage = "{\"Error\": \"AwsS3.uploadAnalytics \(jsonError.localizedDescription)\"}"
            message = errorMessage.data(using: String.Encoding.utf8)!
        }
        // debug
        print("message \(String(describing: String(data: message, encoding: String.Encoding.utf8)))")
        uploadAnalytics(sessionId: sessionId, timestamp: timestamp, prefix: prefix, json: message,
                   complete: complete)
    }
    /**
    * Upload Analytics from a JSON text String in Data form.  This one is intended for the Cordova Plugin to use
    */
    public func uploadAnalytics(sessionId: String, timestamp: String, prefix: String, json: Data,
                                complete: @escaping (_ error: Error?) -> Void) {
        let s3Bucket = "analytics-" + self.endpoint.regionName + "-shortsands"
        let s3Key = sessionId + "-" + timestamp
        let jsonPrefix = "{\"" + prefix + "\": "
        let jsonSuffix = "}"
        var message: Data = jsonPrefix.data(using: String.Encoding.utf8)!
        message.append(json)
        message.append(jsonSuffix.data(using: String.Encoding.utf8)!)
        uploadData(s3Bucket: s3Bucket, s3Key: s3Key, data: message,
                   contentType: "application/json", complete: complete)
    }
    /**
    * Upload string object to bucket
    */
    public func uploadText(s3Bucket: String, s3Key: String, data: String, contentType: String,
                      complete: @escaping (_ error: Error?) -> Void) {
        let textData = data.data(using: String.Encoding.utf8)
        uploadData(s3Bucket: s3Bucket, s3Key: s3Key, data: textData!, contentType: contentType, complete: complete)
    }
    /**
     * Upload object in Data form to bucket.  Data must be prepared to correct form
     * before calling this function.
     */
    public func uploadData(s3Bucket: String, s3Key: String, data: Data, contentType: String,
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
    * Warning: This method is only included to permit symmetric testing of download/upload
    * It does not use the uploadFile method of TransferUtility, but uploads data.
    * So, it should not be used for large object unless it is fixed.  I was not
    * able to get the uploadFile method of TransferUtility to work
    */
    public func uploadFile(s3Bucket: String, s3Key: String, filePath: URL, contentType: String,
                    complete: @escaping (_ error: Error?) -> Void) {
        do {
            let data = try Data(contentsOf: filePath, options: Data.ReadingOptions.uncached)
            uploadData(s3Bucket: s3Bucket, s3Key: s3Key, data: data, contentType: contentType,
                       complete: complete)
        } catch let cotError {
            print("ERROR in s3.uploadFile, while reading file \(s3Bucket) \(s3Key) \(cotError.localizedDescription)")
            complete(cotError)
        }
    }
}
