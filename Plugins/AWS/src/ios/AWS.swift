//
//  AWS.swift
//  AWS
//
//  Created by Gary Griswold on 5/15/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
/**
* This class is the cordova native interface code that calls the AwsS3.
* It is a thin wrapper around the AwsS3 class that AwsS3 can also 
* be used directly by other .swift classes.
*/
import AWS

@objc(AWS) class AWS : CDVPlugin {
	
	static var regionType: AWSRegionType = AWSRegionType.USEast1
	
	var awsS3: AwsS3 = AwsS3(region: regionType)  // I don't see this constructor is ever executed
								// but if it does get executed, will it crash AwsS3?
    
    @objc(initializeRegion:)
    func initializeRegion(command:  CDVInvokedUrlCommand) {
        let regionName = command.arguments[0] as? String ?? ""
        let type: AWSRegionType = regionName.aws_regionTypeValue()
        var result: CDVPluginResult
        if (type != AWSRegionType.Unknown) {
            AWS.regionType = type
            result = CDVPluginResult(status: CDVCommandStatus_OK)
        } else {
            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Unknown Region: " + regionName)
        }
        self.awsS3 = AwsS3(region: AWS.regionType)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
	
	@objc(echo2:) 
	func echo2(command:  CDVInvokedUrlCommand) {
		let message = command.arguments[0] as? String ?? ""
		let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
		self.commandDelegate!.send(result, callbackId: command.callbackId)
	}
	
	@objc(echo3:)
	func echo3(command: CDVInvokedUrlCommand) {
		let message = command.arguments[0] as? String ?? ""
		let response = self.awsS3.echo3(message: message);
		let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: response)
		self.commandDelegate!.send(result, callbackId: command.callbackId)		
	}
	
	@objc(preSignedUrlGET:) 
	func preSignedUrlGET(command: CDVInvokedUrlCommand) {
		awsS3.preSignedUrlGET(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			expires: command.arguments[2] as? Int ?? 3600,
			complete: { url in 
				let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: url?.absoluteString)
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		)
	}
	
	@objc(preSignedUrlPUT:) 
	func preSignedUrlPUT(command: CDVInvokedUrlCommand) {
		awsS3.preSignedUrlPUT(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			expires: command.arguments[2] as? Int ?? 3600,
			contentType: command.arguments[3] as? String ?? "",
			complete: { url in 
				let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: url?.absoluteString)
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		)
	}

	@objc(downloadText:) 
	func downloadText(command: CDVInvokedUrlCommand) {
		awsS3.downloadText(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
            complete: { error, data in
            	var result: CDVPluginResult
            	if let err = error {
	            	result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
            	} else {
	            	result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data)
            	}
            	self.commandDelegate!.send(result, callbackId: command.callbackId)
            }
        )
    }
    
    @objc(downloadData:) 
    func downloadData(command: CDVInvokedUrlCommand) {	
		awsS3.downloadData(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
            complete: { error, data in
	            var result: CDVPluginResult
	            if let err = error {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArrayBuffer: data)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }
        )
    }
    
    @objc(downloadFile:) 
    func downloadFile(command: CDVInvokedUrlCommand) {
	    print("Documents \(NSHomeDirectory())") 
	    let filePath: String = command.arguments[2] as? String ?? ""
	    awsS3.downloadFile(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			filePath: URL(fileURLWithPath: NSHomeDirectory() + filePath),
            complete: { error in
	            var result: CDVPluginResult
		        if let err = error {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }	    
	    )
    }
    
    @objc(downloadZipFile:) 
    func downloadZipFile(command: CDVInvokedUrlCommand) {
	    print("Documents \(NSHomeDirectory())") 
	    let filePath: String = command.arguments[2] as? String ?? ""
	    awsS3.downloadZipFile(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			filePath: URL(fileURLWithPath: NSHomeDirectory() + filePath),
            complete: { error in
	            var result: CDVPluginResult
	            if let err = error {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }	    
	    )
    }
    
    @objc(uploadVideoAnalytics:) 
    func uploadVideoAnalytics(command: CDVInvokedUrlCommand) {    
	    awsS3.uploadVideoAnalytics(
		    sessionId: command.arguments[0] as? String ?? "", 
		    timestamp: command.arguments[1] as? String ?? "", 
		    data: command.arguments[2] as? String ?? "",
            complete: { error in
	            var result: CDVPluginResult
	            if let err = error {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }		    
	    )
    }
    
    @objc(uploadText:) 
    func uploadText(command: CDVInvokedUrlCommand) {    
	    awsS3.uploadText(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
		    data: command.arguments[2] as? String ?? "",
            complete: { error in
	            var result: CDVPluginResult
	            if let err = error {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }	    
	    )
    }
    
    @objc(uploadData:) 
    func uploadData(command: CDVInvokedUrlCommand) {
	    awsS3.uploadData(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
		    data: command.arguments[2] as? Data ?? Data(),
		    contentType: command.arguments[3] as? String ?? "",
            complete: { error in
	            var result: CDVPluginResult
	            if let err = error {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }		    
	    )
    }
    
    /**
    * Warning: this does not use the uploadFile method of TransferUtility,
	* See note in AwsS3.uploadFile for more info.
    */
    @objc(uploadFile:) 
    func uploadFile(command: CDVInvokedUrlCommand) {
	    let filePath = command.arguments[2] as? String ?? ""
	    awsS3.uploadFile(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			filePath: URL(fileURLWithPath: NSHomeDirectory() + filePath),
			contentType: command.arguments[3] as? String ?? "",
            complete: { error in
            	var result: CDVPluginResult
				if let err = error {
	            	result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: err.localizedDescription)
				} else {
	            	result = CDVPluginResult(status: CDVCommandStatus_OK)
				}
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
	    )
    }
}		
