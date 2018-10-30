//
//  SettingsNavigationController.swift
//  Settings
//
//  Created by Gary Griswold on 8/2/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

public class ReaderViewNavigator {
    
    var navController: UINavigationController?
    var viewController: UIViewController?
    
    deinit {
        print("**** deinit ReaderViewNavigator ******")
    }
    
    public func present() -> UINavigationController {
        self.viewController = ReaderPageController()
        //self.viewController = ReaderViewController()
        //let viewController = SettingsViewController(settingsViewType: .primary)
        //let viewController = SettingsViewController(settingsViewType: .language)
        //let viewController = SettingsViewController(settingsViewType: .version)
        //let viewController = FeedbackViewController()
        //let viewController = VersionDetailViewController()
        self.navController = UINavigationController(rootViewController: self.viewController!)
        self.navController!.hidesBarsOnSwipe = false // true prevents cell move from working
        _ = StoreReviewController.shared  // This could be postponed more
        return navController!
    }
    
}
