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
@objc(AWS) class AWS : CDVPlugin {
	
	let awsS3: AwsS3 = AwsS3()
	
	static func awake() -> Void {}
	
	@objc(echo2:) 
	func echo2(command:  CDVInvokedUrlCommand) {
		let message = command.arguments[0] as? String ?? ""
		let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
		self.commandDelegate!.send(result, callbackId: command.callbackId)
	}
	
	@objc(preSignedUrlGET:) func preSignedUrlGET(command: CDVInvokedUrlCommand) {
		let expires = command.arguments[2] as? String ?? "3600"
		awsS3.preSignedUrlGET(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			expires: Int(expires)!,
			complete: { url in 
				let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: url?.absoluteString)
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		)
	}
	
	@objc(preSignedUrlPUT:) func preSignedUrlPUT(command: CDVInvokedUrlCommand) {
		let expires = command.arguments[2] as? String ?? "3600"
		awsS3.preSignedUrlPUT(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			expires: Int(expires)!,
			contentType: command.arguments[3] as? String ?? "",
			complete: { url in 
				let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: url?.absoluteString)
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		)
	}

	@objc(downloadText:) func downloadText(command: CDVInvokedUrlCommand) {
		
		awsS3.downloadText(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
            complete: { error, data in
            	var result: CDVPluginResult
            	if (error != nil) {
	            	result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
            	} else {
	            	result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data)
            	}
            	self.commandDelegate!.send(result, callbackId: command.callbackId)
            }
        )
    }
    
    @objc(downloadData:) func downloadData(command: CDVInvokedUrlCommand) {
		
		awsS3.downloadData(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
            complete: { error, data in
	            var result: CDVPluginResult
	            if (error != nil) {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArrayBuffer: data)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }
        )
    }
    
    @objc(downloadFile:) func downloadFile(command: CDVInvokedUrlCommand) {
	    
	    let filePath: String = command.arguments[2] as? String ?? ""
	    
	    awsS3.downloadFile(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			filePath: filePath,
            complete: { error in
	            var result: CDVPluginResult
	            if (error != nil) {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }	    
	    )
    }
    
    @objc(downloadZipFile:) func downloadZipFile(command: CDVInvokedUrlCommand) {
	    
	    let filePath: String = command.arguments[2] as? String ?? ""
	    
	    awsS3.downloadZipFile(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			filePath: filePath,
            complete: { error in
	            var result: CDVPluginResult
	            if (error != nil) {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }	    
	    )
    }
    
    @objc(uploadVideoAnalytics:) func uploadVideoAnalytics(command: CDVInvokedUrlCommand) {
	    
	    awsS3.uploadVideoAnalytics(
		    sessionId: command.arguments[0] as? String ?? "", 
		    timestamp: command.arguments[1] as? String ?? "", 
		    data: command.arguments[2] as? String ?? "",
            complete: { error in
	            var result: CDVPluginResult
	            if (error != nil) {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }		    
	    )
    }
    
    @objc(uploadText:) func uploadText(command: CDVInvokedUrlCommand) {
	    
	    awsS3.uploadText(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
		    data: command.arguments[2] as? String ?? "",
            complete: { error in
	            var result: CDVPluginResult
	            if (error != nil) {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }	    
	    )
    }
    
    @objc(uploadData:) func uploadData(command: CDVInvokedUrlCommand) {
	    
	    //let bytes: NSData? = command.arguments[2] as? NSData ?? nil
	    let bytes: Data = command.arguments[2] as? Data ?? Data()
	    //let data = Data(bytes)
	    
	    awsS3.uploadData(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
		    data: bytes,
		    contentType: command.arguments[3] as? String ?? "",
            complete: { error in
	            var result: CDVPluginResult
	            if (error != nil) {
		            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
	            } else {
		            result = CDVPluginResult(status: CDVCommandStatus_OK)
	            }
	            self.commandDelegate!.send(result, callbackId: command.callbackId)
	        }		    
	    )
    }
    
    @objc(uploadFile:) func uploadFile(command: CDVInvokedUrlCommand) {
	    
	    let filePath: String = command.arguments[2] as? String ?? ""
	    
	    awsS3.uploadFile(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			filePath: filePath,
			contentType: command.arguments[3] as? String ?? "",
            complete: { error in
            	var result: CDVPluginResult
				if (error != nil) {
	            	result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error!.localizedDescription)
				} else {
	            	result = CDVPluginResult(status: CDVCommandStatus_OK)
				}
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
	    )
    }			
}		
