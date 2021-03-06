//
//  StoreReviewController.swift
//  Settings
//
//  Created by Gary Griswold on 9/27/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import StoreKit
/**
 * This class accumulates the total seconds use of the App, and everytime
 * that use reaches a threshold (at this time 30 min), it attempts to present
 * the App review dialog.
 */
class StoreReviewController {
    
    public static var shared = StoreReviewController() // var for lazy initialization
    
    private static let APP_USE_SEC = "app_use_sec"
    private static let REVIEW_INTERVAL_SEC = 1800.0 // 30 min
    
    private var appStart: Double = CFAbsoluteTimeGetCurrent()
    private var timer: Timer?
    
    private init() {
        let notify = NotificationCenter.default
        notify.addObserver(self,
                           selector: #selector(startTimer(note:)),
                           name: UIApplication.didFinishLaunchingNotification,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(startTimer(note:)),
                           name: UIApplication.willEnterForegroundNotification,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(completeTimer(note:)),
                           name: UIApplication.didEnterBackgroundNotification,
                           object: nil)
        notify.addObserver(self,
                           selector: #selector(completeTimer(note:)),
                           name: UIApplication.willTerminateNotification,
                           object: nil)
    }
    
    deinit {
        print("****** deinit StoreReviewController ******")
    }
    
    @objc func startTimer(note: Notification) {
        print("**** Start StoreReview Timer ****")
        self.appStart = CFAbsoluteTimeGetCurrent()
        let settings = UserDefaults.standard
        let seconds = settings.double(forKey: StoreReviewController.APP_USE_SEC)
        let remainder = seconds.truncatingRemainder(dividingBy: StoreReviewController.REVIEW_INTERVAL_SEC)
        let secToNext = StoreReviewController.REVIEW_INTERVAL_SEC - remainder
        print("seconds \(seconds)  remainer \(remainder)  secToNext \(secToNext)")
        self.timer = Timer.scheduledTimer(timeInterval: secToNext, target: self, selector:
            #selector(self.showReviewDialog), userInfo: nil, repeats: false)
    }
    @objc func showReviewDialog() {
        print("StoreReviewController called")
        SKStoreReviewController.requestReview()
    }
    @objc func completeTimer(note: Notification) {
        print("**** applicationEnteredBackground or Terminated ****")
        let settings = UserDefaults.standard
        let currentSec = CFAbsoluteTimeGetCurrent() - self.appStart
        var seconds = settings.double(forKey: StoreReviewController.APP_USE_SEC)
        seconds += currentSec
        settings.set(seconds, forKey: StoreReviewController.APP_USE_SEC)
        print("curr use \(currentSec) new seconds \(seconds)")
        self.timer?.invalidate()
    }
}
