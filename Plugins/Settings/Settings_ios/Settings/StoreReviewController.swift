//
//  StoreReviewController.swift
//  Settings
//
//  Created by Gary Griswold on 9/27/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import StoreKit

class StoreReviewController {
    
    public static let shared = StoreReviewController()
    
    private static let APP_USE_SEC = "app_use_sec"
    private static let REVIEW_INTERVAL_SEC = 1800.0 // 30 min
    
    private var appStart: Double = CFAbsoluteTimeGetCurrent()
    private var timer: Timer?
    
    private init() {
        let notify = NotificationCenter.default
        notify.addObserver(self,
                           selector: #selector(startTimer(note:)),
                           name: .UIApplicationDidFinishLaunching,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(startTimer(note:)),
                           name: .UIApplicationWillEnterForeground,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(completeTimer(note:)),
                           name: .UIApplicationDidEnterBackground,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(completeTimer(note:)),
                           name: .UIApplicationWillTerminate,
                           object: nil)
    }
    
    @objc func startTimer(note: Notification) {
        print("**** applicationDidFinishLaunching ****")
        self.appStart = CFAbsoluteTimeGetCurrent()
        let settings = UserDefaults.standard
        let seconds = settings.double(forKey: StoreReviewController.APP_USE_SEC)
        let secToNext = seconds.truncatingRemainder(dividingBy: StoreReviewController.REVIEW_INTERVAL_SEC)
        self.timer = Timer.scheduledTimer(timeInterval: secToNext, target: self, selector:
            #selector(self.showReviewDialog), userInfo: nil, repeats: false)
    }
    @objc func showReviewDialog() {
        SKStoreReviewController.requestReview()
    }
    @objc func completeTimer(note: Notification) {
        print("**** applicationDidEnterBackground ****")
        let settings = UserDefaults.standard
        let currentSec = CFAbsoluteTimeGetCurrent() - self.appStart
        var seconds = settings.double(forKey: StoreReviewController.APP_USE_SEC)
        seconds += currentSec
        settings.set(seconds, forKey: StoreReviewController.APP_USE_SEC)
        self.timer?.invalidate()
    }
}
