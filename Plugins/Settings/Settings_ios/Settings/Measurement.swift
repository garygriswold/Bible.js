//
//  Measurement.swift
//  Settings
//
//  Created by Gary Griswold on 11/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import Foundation

class Measurement {
    
    var start: Double
    
    init() {
        self.start = CFAbsoluteTimeGetCurrent()
    }
    
    func duration(location: String) {
        print("*** \(location): \((CFAbsoluteTimeGetCurrent() - self.start) * 1000) ms")
        self.start = CFAbsoluteTimeGetCurrent()
    }
}
