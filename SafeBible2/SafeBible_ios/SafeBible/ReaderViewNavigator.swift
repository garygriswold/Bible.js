//
//  SettingsNavigationController.swift
//  Settings
//
//  Created by Gary Griswold on 8/2/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit
import Utility

public class ReaderViewNavigator {
    
    var navController: UINavigationController?
    var viewController: UIViewController?
    
    deinit {
        print("**** deinit ReaderViewNavigator ******")
    }
    
    public func present() -> UINavigationController {
        self.checkIfAppUpdate()
        self.viewController = ReaderPagesController()
        self.navController = UINavigationController(rootViewController: self.viewController!)
        self.navController!.hidesBarsOnSwipe = false // true prevents cell move from working
        _ = StoreReviewController.shared  // This could be postponed more
        return navController!
    }
    
    /**
    * This method checks to see if the App is being updated, and removes the database
    * Versions.db if it is an update.  Doing this ensures that the App uses the new
    * Versions.db found in Bundle.main
    */
    private func checkIfAppUpdate() {
        let start = CFAbsoluteTimeGetCurrent()
        let info = Bundle.main.infoDictionary
        let appVersion = info?["CFBundleShortVersionString"] as! String
        print("appVersion \(appVersion)")
        let priorVersion = SettingsDB.shared.getSetting(name: "appVersion")
        print("priorVersion \(String(describing: priorVersion))")
        if appVersion != priorVersion {
            SettingsDB.shared.updateSetting(name: "appVersion", setting: appVersion)
            do {
                try Sqlite3.deleteDB(dbname: "Versions.db")
            } catch let err {
                print("ERROR: ReaderViewNavigator.checkIfAppUpdate \(err)")
            }
        }
        print("*** checkIfAppUpdate duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
}
