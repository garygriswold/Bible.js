//
//  AppDelegate.swift
//  StaticCellsSwift
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let viewController = SettingsViewController(settingsViewType: .primary)
        //let viewController = SettingsViewController(settingsViewType: .language)
        //let viewController = SettingsViewController(settingsViewType: .version)
        //let viewController = FeedbackViewController()
        let navController = UINavigationController(rootViewController: viewController)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

