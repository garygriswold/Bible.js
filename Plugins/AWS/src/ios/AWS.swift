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
//import AWS used for AWS.framework

@objc(AWS) class AWS : CDVPlugin {
						    
    @objc(initializeRegion:)
    func initializeRegion(command:  CDVInvokedUrlCommand) {
        let regionName = command.arguments[0] as? String ?? ""
        AwsS3.region = regionName
        let result = CDVPluginResult(status: CDVCommandStatus_OK)
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
		let response = AwsS3.shared.echo3(message: message);
		let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: response)
		self.commandDelegate!.send(result, callbackId: command.callbackId)		
	}
	
	@objc(preSignedUrlGET:) 
	func preSignedUrlGET(command: CDVInvokedUrlCommand) {
		AwsS3.shared.preSignedUrlGET(
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
		AwsS3.shared.preSignedUrlPUT(
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
		AwsS3.shared.downloadText(
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
		AwsS3.shared.downloadData(
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
	    AwsS3.shared.downloadFile(
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
	    AwsS3.shared.downloadZipFile(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			filePath: URL(fileURLWithPath: NSHomeDirectory() + filePath),
			view: nil,
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
    @objc(uploadAnalytics:) 
    func uploadVideoAnalytics(command: CDVInvokedUrlCommand) {
	    let data = command.arguments[3] as? String ?? ""
	    AwsS3.shared.uploadAnalytics(
		    sessionId: command.arguments[0] as? String ?? "", 
		    timestamp: command.arguments[1] as? String ?? "",
		    prefix: command.arguments[2] as? String ?? "",
		    json: data.data(using: String.Encoding.utf8)!,
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
	    AwsS3.shared.uploadText(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
		    data: command.arguments[2] as? String ?? "",
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
    
    @objc(uploadData:) 
    func uploadData(command: CDVInvokedUrlCommand) {
	    AwsS3.shared.uploadData(
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
	    AwsS3.shared.uploadFile(
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
