//
//  Timer.swift
//  AWS_Testharness
//
//  Created by Gary Griswold on 4/6/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation

class Timer {
    
    var currentTime: CFAbsoluteTime
    
    init(place: String) {
        currentTime = CFAbsoluteTimeGetCurrent()
        print("START \(place)")
    }
    
    func duration(place: String) {
        let duration = CFAbsoluteTimeGetCurrent() - currentTime
        print("AT \(place)  \(duration) sec")
        currentTime = CFAbsoluteTimeGetCurrent()
    }
}
