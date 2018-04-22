//
//  Utility.swift
//  Utility
//
//  Created by Gary Griswold on 1/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit

/*
 platform, modelType, modelName, deviceSize
 */

@objc(Utility) class Utility : CDVPlugin {
    
    @objc(platform:) func platform(command: CDVInvokedUrlCommand) {
        let message = "iOS"
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
    
    @objc(modelType:) func modelType(command: CDVInvokedUrlCommand) {
        let message = UIDevice.current.model
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
    
    @objc(modelName:) func modelName(command: CDVInvokedUrlCommand) {
        let message = DeviceSettings.modelName()
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
    
    @objc(deviceSize:) func deviceSize(command: CDVInvokedUrlCommand) {
        let message = DeviceSettings.deviceSize()
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
    
    @objc(open:) func open(command: CDVInvokedUrlCommand) {
	    DispatchQueue.global().async {
		    var result: CDVPluginResult
		    do {
		    	let database = try Sqlite3.openDB(
		    				dbname: command.arguments[0] as? String ?? "",
		    				copyIfAbsent: command.arguments[1] as? Bool ?? false)
		    	result = CDVPluginResult(status: CDVCommandStatus_OK)
		    } catch let err {
			    let message = Sqlite3.errorDescription(error: err)
			    result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message)
			}
			self.commandDelegate!.send(result, callbackId: command.callbackId)
		}
	}
	
    @objc(queryJS:) func queryJS(command: CDVInvokedUrlCommand) {
	    DispatchQueue.global().async {
		    var result: CDVPluginResult? = nil
		    do {
			    let database = try Sqlite3.findDB(dbname: command.arguments[0] as? String ?? "")
			    try database.queryJS(
				    		sql: command.arguments[1] as? String ?? "",
				    		values: command.arguments[2] as? [String?] ?? [],
				    		complete: { resultSet in
				    			let json = String(data: resultSet, encoding: String.Encoding.utf8)
					    		result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
					    		self.commandDelegate!.send(result, callbackId: command.callbackId)
				    		})
			} catch let err {
				let message = Sqlite3.errorDescription(error: err)    	
			    result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message)
			    self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		}
	}
	
	@objc(executeV1:) func executeV1(command: CDVInvokedUrlCommand) {
		DispatchQueue.global().async {
		    var result: CDVPluginResult? = nil
		    do {
			    let database = try Sqlite3.findDB(dbname: command.arguments[0] as? String ?? "")
			    try database.executeV1(
				    		sql: command.arguments[1] as? String ?? "",
				    		values: command.arguments[2] as? [String?] ?? [],
				    		complete: { rowCount in
					    		result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: rowCount)
					    		self.commandDelegate!.send(result, callbackId: command.callbackId)
				    		})
			} catch let err {
				let message = Sqlite3.errorDescription(error: err)  	
			    result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message)
			    self.commandDelegate!.send(result, callbackId: command.callbackId)
			}
		}
	}
	
	@objc(close:) func close(command: CDVInvokedUrlCommand) {
		DispatchQueue.global().async {
		    var result: CDVPluginResult
		    Sqlite3.closeDB(dbname: command.arguments[0] as? String ?? "")
			result = CDVPluginResult(status: CDVCommandStatus_OK)
		    self.commandDelegate!.send(result, callbackId: command.callbackId)
	    }
	}
}
