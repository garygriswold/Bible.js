//
//  AppDelegate.swift
//  Settings
//

import UIKit
import Utility

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        do {
            try Sqlite3.openDB(dbname: "Versions.db", copyIfAbsent: true)
        } catch let err {
            print("Could not open Versions.db \(err)")
        }

        //let viewController = SettingsViewController(settingsViewType: .primary)
        //let viewController = SettingsViewController(settingsViewType: .language)
        //let viewController = SettingsViewController(settingsViewType: .version)
        //let viewController = FeedbackViewController()
        //let navController = UINavigationController(rootViewController: viewController)
        
        let settingsNavigator = SettingsNavigator()
        let navController = settingsNavigator.present()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

