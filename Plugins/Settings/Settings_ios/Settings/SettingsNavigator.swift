//
//  SettingsNavigationController.swift
//  Settings
//
//  Created by Gary Griswold on 8/2/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

public class SettingsNavigator {
    
    deinit {
        print("**** deinit SettingsNavigator ******")
    }
    
    public func present() -> UINavigationController {
        let viewController = ReaderViewController()
        //let viewController = SettingsViewController(settingsViewType: .primary)
        //let viewController = SettingsViewController(settingsViewType: .language)
        //let viewController = SettingsViewController(settingsViewType: .version)
        //let viewController = FeedbackViewController()
        //let viewController = VersionDetailViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.hidesBarsOnSwipe = false // true prevents cell move from working
        let review = StoreReviewController.shared  // This could be postponed more
        return navController
    }
    
}
