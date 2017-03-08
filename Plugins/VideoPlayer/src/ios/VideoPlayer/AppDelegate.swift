/**
 *  AppDelegate.swift
 *  VideoPlayer
 *
 *  Created by Gary Griswold on 1/16/17.
 *  Copyright © 2017 ShortSands. All rights reserved.
 *
 * *** This class is deprecated.  It was needed to write a
 * standalone video player application, but it is not part of the
 * videoplayer plugin.
 */
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var viewController: VideoViewController = VideoViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = self.window ?? UIWindow()
        self.window!.rootViewController = viewController
        self.window!.makeKeyAndVisible()
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("\n***** ApplicationWillResignActive in AppDelegate")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("\n****** ApplicationDidEnterBackground in AppDelegate")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("\n****** ApplicationDidEnterForground in AppDelegate")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("\n****** ApplicationDidBecomeActive in AppDelegate")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    func applicationWillTerminate(_ application: UIApplication) {
        print("\n****** ApplicationWillTerminate in AppDelegate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}



