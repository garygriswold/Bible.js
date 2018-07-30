//
//  AppDelegate.swift
//  StaticCellsSwift
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //let tableViewController = SettingsViewController()
        let tableViewController = LanguageViewController()
        //let tableViewController = VersionViewController()
        let navController = UINavigationController(rootViewController: tableViewController)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

