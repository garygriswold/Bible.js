//
//  AwsS3Plugin.swift
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
@objc(AwsS3Plugin) class AwsS3Plugin : CDVPlugin {
	
	let awsS3: AwsS3 = AwsS3()
	
	@objc(preSignedUrlGET:) func preSignedUrlGET(command: CDVInvokedUrlCommand) {
		
		awsS3.preSignedUrlGET(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			expires: command.arguments[2] as int ?? 0,
			complete: { url in 
				let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: url.toString())
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		)
	}
	
	@objc(preSignedUrlPUT:) func preSignedUrlPUT(command: CDVInvokedUrlCommand) {
		
		awsS3.preSignedUrlPUT(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
			expires: command.arguments[2] as? int ?? 0,
			contentType: command.arguments[3] as? String ?? "",
			complete: { url in 
				let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: url.toString())
				self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		)
	}

	@objc(downloadText:) func downloadText(command: CDVInvokedUrlCommand) {
		
		awsS3.downloadText(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
            complete: { error, data in
            	var result = null;
            	if (error != null) {
	            	result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: url.toString())
            	} else {
	            	result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data);
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
            	// data becomes ArrayBuffer in JS, I think
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
            	self.commandDelegate!.send(result, callbackId: command.callbackId)
            }		    
	    )
    }
    
    @objc(uploadData:) func uploadData(command: CDVInvokedUrlCommand) {
	    
	    let bytes: NSData = command.arguments[2] as? NSData ?? nil
	    let data = Data(bytes)
	    
	    awsS3.uploadData(
			s3Bucket: command.arguments[0] as? String ?? "",
			s3Key: command.arguments[1] as? String ?? "",
		    data: data,
		    contentType: command.arguments[3] as? String ?? ""
            complete: { error in
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
			contentType: command.arguments[3] as? String ?? ""
            complete: { error in
            	self.commandDelegate!.send(result, callbackId: command.callbackId)
            }		    
	    )
    }			
}		
