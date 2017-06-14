//
//  AwsS3.swift
//  AWS_S3_Prototype
//
//  Created by Gary Griswold on 5/15/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AWSCore
import ZipArchive


public class AwsS3 {
    
    static let VIDEO_ANALYTICS_BUCKET = "video.analytics.shortsands"
    
    private var transfer: AWSS3TransferUtility
    
    init(region: AWSRegionType) {
	    let endpoint = AWSEndpoint(region: region, service: AWSServiceType.S3, useUnsafeURL: false)!
        let configuration = AWSServiceConfiguration(region: region, endpoint: endpoint,
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
		self.transfer.downloadData(fromBucket: s3Bucket, key: s3Key, expression: nil, completionHandler: completionHandler)
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
		self.transfer.downloadData(fromBucket: s3Bucket, key: s3Key, expression: nil, completionHandler: completionHandler)
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
                    } catch let cotError {
                        print("Error in s3.downloadFile \(s3Bucket) \(s3Key) \(cotError)")
                        complete(cotError) // pass error here, if I knew how to catch or create one.
                    }
                }
            })
        }
        self.transfer.downloadData(fromBucket: s3Bucket, key: s3Key, expression: nil, completionHandler: completionHandler)
        //.continueWith has been dropped, because it did not report errors
    }   
    /**
    * Download zip file and unzip it.  Like Download File this does not use 
    * TransferUtility.fileDownload because its error reporting is poor.
    */
    func downloadZipFile(s3Bucket: String, s3Key: String, filePath: URL,
                         complete: @escaping (_ error:Error?) -> Void) {                   
        let completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock = {(task, url, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    print("ERROR in s3.downloadZipFile \(s3Bucket) \(s3Key) Error: \(err)")
                    complete(err)
                } else {
	               	let fileManager = FileManager.default  
	               	var tempZipURL: URL
                    do {
	                    // save the zipped data to a file
	                    tempZipURL = URL(fileURLWithPath: NSTemporaryDirectory() + NSUUID().uuidString + ".zip")
						print("temp URL to store file \(tempZipURL)")
                        try data?.write(to: tempZipURL, options: Data.WritingOptions.atomic)
                        
                        // unzip zip file
                        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
                        try self.unzip(sourceFile: tempZipURL, targetDir: tempDirURL)
                        
                        // identify the unzipped file
						let filename = filePath.lastPathComponent
						let unzippedURL = URL(fileURLWithPath: NSTemporaryDirectory() + filename)
						print("location of unzipped file \(unzippedURL)")
						
						// remove unzipped file if it already exists
						if (try filePath.checkPromisedItemIsReachable()) {
							try fileManager.removeItem(at: filePath)
						}
			
						// move unzipped file to destination
						print("Before move item")
                        try fileManager.moveItem(at: unzippedURL, to: filePath)
                        print("SUCCESS in s3.downloadZipFile \(s3Bucket) \(s3Key)")
                        complete(nil)
                    } catch let cotError {
	                    print("ERROR in s3.downloadZipFile \(s3Bucket) \(s3Key) Error: \(cotError)")
                        complete(cotError)
                    }
                    do {
	                    try fileManager.removeItem(at: tempZipURL)
                    } catch let cotError2 {
	                    print("Deletion of tempZipFile Failed \(cotError2.localizedDescription)")
                    }
                }
            })
        }
        self.transfer.downloadData(fromBucket: s3Bucket, key: s3Key, expression: nil, completionHandler: completionHandler)
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
            let data = try Data(contentsOf: filePath, options: Data.ReadingOptions.uncached)
            uploadData(s3Bucket: s3Bucket, s3Key: s3Key, data: data, contentType: contentType,
                       complete: complete)
        } catch let cotError {
            print("ERROR in s3.uploadFile, while reading file \(s3Bucket) \(s3Key) \(cotError.localizedDescription)")
            complete(cotError)
        }
    }
    /////////////////////////////////////////////////////////////////////////
    // Zip Functions
    /////////////////////////////////////////////////////////////////////////
    /**
     * Zip Utility for zipping a single file. Notice that the Zip.zipFiles func
     * used does have the ability to handle multiple input files.
     */
    func zip(sourceFile: URL, targetFile: URL) throws -> Void {
        let done = SSZipArchive.createZipFile(atPath: sourceFile.absoluteString,
                                              withContentsOfDirectory: targetFile.absoluteString)
        print("Zip success \(done)")
		//	try Zip.zipFiles(paths: [sourceFile], zipFilePath: targetFile,
		//	                 password: nil, progress: nil)
    }
    /**
     * UnZip Utility for use on files.
     */
    func unzip(sourceFile: URL, targetDir: URL) throws -> Void {
        let done = SSZipArchive.unzipFile(atPath: sourceFile.absoluteString,
                                          toDestination: targetDir.absoluteString)
        print("UnZip success \(done)")
	    //try Zip.unzipFile(sourceFile, destination: targetDir, overwrite: true,
	    //	              password: nil, progress: nil)
    }
}
