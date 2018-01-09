//
//  Utility.swift
//  TempDevice
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
}
