//
//  DeviceSettings.swift
//  TempDevice
//
//  Created by Gary Griswold on 1/8/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import UIKit
/*
public class DeviceSettings {
    
    public static func modelName() -> String {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let DEVICE_IS_SIMULATOR = true
        #else
            let DEVICE_IS_SIMULATOR = false
        #endif
        
        var machineString : String = ""
        
        if DEVICE_IS_SIMULATOR == true {
            
            if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                machineString = dir
            }
        }
        else {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            machineString = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        }
        if machineString.prefix(4) == "iPad" {
            return "iPad"
        }
        if machineString.prefix(6) == "iPhone" {
            let parts = machineString.split(separator: ",")
            let major: String = String(parts[0])
            let len = major.count - 6
            let num1: Int = Int(major.suffix(len)) ?? 0
            let num2: Int = Int(parts[1]) ?? 0
            if num1 == 10 && (num2 == 3 || num2 == 6) {
                return "iPhone X"
            }
            if num1 > 10 {
                return "iPhone X"
            }
            else {
                return "iPhone"
            }
        }
        else {
            return machineString
        }
        //switch machine {
        //case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        //case "iPhone4,1":                               return "iPhone 4s"
        //case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        //case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        //case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        //case "iPhone7,2":                               return "iPhone 6"
        //case "iPhone7,1":                               return "iPhone 6 Plus"
        //case "iPhone8,1":                               return "iPhone 6s"
        //case "iPhone8,2":                               return "iPhone 6s Plus"
        //case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        //case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        //case "iPhone8,4":                               return "iPhone SE"
        //case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        //case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        //case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        //case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        //case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        //case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        //case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        //case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        //case "iPad6,11", "iPad6,12":                    return "iPad 5"
        //case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        //case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        //case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        //case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        //case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        //case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        //case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        //case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        //case "i386", "x86_64":                          return "Simulator"
        //default:                                        return machineString
        //}
    }
    
    public static func deviceSize() -> String {
        let height = UIScreen.main.nativeBounds.height
        let width = UIScreen.main.nativeBounds.width
        let bigger = max(height, width)
        switch bigger {
        case 1136:
            return "iPhone 5/5s/5c/SE"
        case 1334:
            return "iPhone 6/6s/7/8"
        case 2048:
            return "iPad 5/Air/Air 2/Pro 9.7 Inch"
        case 2208:
            return "iPhone 6+/6s+/7+/8+"
        case 2224:
            return "iPad Pro 10.5 Inch"
        case 2436:
            return "iPhone X"
        case 2732:
            return "iPad Pro 12.9 Inch"
        default:
            return "type Unknown \(width) \(height)"
        }
    }
}
 */

