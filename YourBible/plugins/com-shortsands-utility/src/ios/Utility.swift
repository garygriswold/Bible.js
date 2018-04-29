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
	    DispatchQueue.global().sync {
		    do {
		    	let database = try Sqlite3.openDB(
		    				dbname: command.arguments[0] as? String ?? "",
		    				copyIfAbsent: command.arguments[1] as? Bool ?? false)
		    	let result = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(result, callbackId: command.callbackId)
		    } catch let err {
                self.returnError(error: err, command: command)
			}
		}
	}
	
    @objc(queryJS:) func queryJS(command: CDVInvokedUrlCommand) {
	    DispatchQueue.global().sync {
		    do {
			    let database = try Sqlite3.findDB(dbname: command.arguments[0] as? String ?? "")
			    let resultSet = try database.queryJS(
				    		sql: command.arguments[1] as? String ?? "",
				    		values: command.arguments[2] as? [Any?] ?? [])
                let json = String(data: resultSet, encoding: String.Encoding.utf8)
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: json)
                self.commandDelegate!.send(result, callbackId: command.callbackId)
			} catch let err {
                self.returnError(error: err, command: command)
			}
		}
	}
	
	@objc(executeJS:) func executeJS(command: CDVInvokedUrlCommand) {
		DispatchQueue.global().sync {
		    do {
			    let database = try Sqlite3.findDB(dbname: command.arguments[0] as? String ?? "")
			    let rowCount = try database.executeV1(
				    		sql: command.arguments[1] as? String ?? "",
				    		values: command.arguments[2] as? [Any?] ?? [])
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: rowCount)
                self.commandDelegate!.send(result, callbackId: command.callbackId)
			} catch let err {
				self.returnError(error: err, command: command)
			}
		}
	}
	
	@objc(close:) func close(command: CDVInvokedUrlCommand) {
		DispatchQueue.global().sync {
		    Sqlite3.closeDB(dbname: command.arguments[0] as? String ?? "")
			let result = CDVPluginResult(status: CDVCommandStatus_OK)
		    self.commandDelegate!.send(result, callbackId: command.callbackId)
	    }
	}
    
    @objc(listDB:) func listDB(command: CDVInvokedUrlCommand) {
        do {
            let files = try Sqlite3.listDB()
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: files)
            self.commandDelegate!.send(result, callbackId: command.callbackId)
        } catch let err {
            self.returnError(error: err, command: command)
        }
    }
    
    @objc(deleteDB:) func deleteDB(command: CDVInvokedUrlCommand) {
        do {
            try Sqlite3.deleteDB(dbname: command.arguments[0] as? String ?? "")
            let result = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate!.send(result, callbackId: command.callbackId)
        } catch let err {
            self.returnError(error: err, command: command)
        }
    }
    
    private func returnError(error: Error, command: CDVInvokedUrlCommand) {
        let message = Sqlite3.errorDescription(error: error)
        let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: message)
        self.commandDelegate!.send(result, callbackId: command.callbackId)
    }
}
