//
//  PKZip.swift
//  PKZip
//
//  Created by Gary Griswold on 6/13/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//
/**
* This class is the cordova native interface code that calls the ZipArchive.
* It is a thin wrapper around the Zip class that Zip can also 
* be used directly by other .swift classes.
*/
import Zip

@objc(PKZip) class PKZip : CDVPlugin {
    
	@objc(zip:)
	func zip(command: CDVInvokedUrlCommand) {
		print("Documents \(NSHomeDirectory())")
		var result: CDVPluginResult
		let sourceFile = command.arguments[0] as? String ?? ""
		let targetFile = command.arguments[1] as? String ?? ""
		do {
			try Zip.zipFiles(
				paths: [ URL(fileURLWithPath: NSHomeDirectory() + sourceFile) ],
				zipFilePath: URL(fileURLWithPath: NSHomeDirectory() + targetFile),
				password: nil,
				progress: nil
			)
			result = CDVPluginResult(status: CDVCommandStatus_OK)
		} catch let error as ZipError {
	        result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.description + " " + sourceFile)
		} catch let error {
			result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription + " " + sourceFile)
		}
		self.commandDelegate!.send(result, callbackId: command.callbackId)
	}
	
	@objc(unzip:)
	func unzip(command: CDVInvokedUrlCommand) {
		print("Documents \(NSHomeDirectory())")
		var result: CDVPluginResult
		let sourceFile = command.arguments[0] as? String ?? ""
		let targetDir = command.arguments[1] as? String ?? ""
		do {
			try Zip.unzipFile(
				URL(fileURLWithPath: NSHomeDirectory() + sourceFile),
				destination: URL(fileURLWithPath: NSHomeDirectory() + targetDir),
				overwrite: true, 
				password: nil,
				progress: nil
			)
			result = CDVPluginResult(status: CDVCommandStatus_OK)
		} catch let error as ZipError {
			result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.description + " " + sourceFile)
        } catch let error {
            result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription + " " + sourceFile)
        }
		self.commandDelegate!.send(result, callbackId: command.callbackId)
	}			

}		
