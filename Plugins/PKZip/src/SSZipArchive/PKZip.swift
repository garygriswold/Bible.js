//
//  PKZip.swift
//  PKZip
//
//  Created by Gary Griswold on 6/13/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
/**
* This class is the cordova native interface code that calls the ZipArchive.
* It is a thin wrapper around the SSZipArchive class that SSZipArchive can also 
* be used directly by other .swift classes.
*/
@objc(PKZip) class PKZip : CDVPlugin {
    
	@objc(zip:)
	func zip(command: CDVInvokedUrlCommand) {
		print("Documents \(NSHomeDirectory())")
		var result: CDVPluginResult
		let sourceFile = command.arguments[0] as? String ?? ""
		let targetFile = command.arguments[1] as? String ?? ""
        let done = SSZipArchive.createZipFile(
        			atPath: URL(fileURLWithPath: NSHomeDirectory() + sourceFile),
					withContentsOfDirectory: URL(fileURLWithPath: NSHomeDirectory() + targetFile))
		if (done) {
			result = CDVPluginResult(status: CDVCommandStatus_OK)
		} else {
	        result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Zip failed.")
		}
		self.commandDelegate!.send(result, callbackId: command.callbackId)
	}
	
	@objc(unzip:)
	func unzip(command: CDVInvokedUrlCommand) {
		print("Documents \(NSHomeDirectory())")
		var result: CDVPluginResult
		let sourceFile = command.arguments[0] as? String ?? ""
		let targetDir = command.arguments[1] as? String ?? ""
        let done = SSZipArchive.unzipFile(atPath: NSHomeDirectory() + sourceFile,
                                          toDestination: NSHomeDirectory() + targetDir))
        if (done) {
			result = CDVPluginResult(status: CDVCommandStatus_OK)
		} catch {
			result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Unzip failed.")
		}
		self.commandDelegate!.send(result, callbackId: command.callbackId)
	}			
}		
