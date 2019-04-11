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
    var prior: Double
    
    init() {
        self.start = CFAbsoluteTimeGetCurrent()
        self.prior = self.start
    }
    
    func duration(location: String) {
        print("*** \(location): \((CFAbsoluteTimeGetCurrent() - self.prior) * 1000) ms")
        self.prior = CFAbsoluteTimeGetCurrent()
    }
    
    func final(location: String) {
        print("*** \(location): \((CFAbsoluteTimeGetCurrent() - self.prior) * 1000) ms")
        print("*** Total: \((CFAbsoluteTimeGetCurrent() - self.start) * 1000) ms")
    }
}
