//
//  AppDelegate.swift
//  Settings
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let readerNavigator = ReaderViewNavigator()
        let navController = readerNavigator.present()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navController
        self.window!.rootViewController!.view.backgroundColor = AppFont.backgroundColor
        self.window!.makeKeyAndVisible()
        
        return true
    }
}

