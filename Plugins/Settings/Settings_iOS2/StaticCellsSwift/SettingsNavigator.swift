//
//  SettingsNavigationController.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 8/2/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

public class SettingsNavigator {
    
    public func present() -> UINavigationController {
        let viewController = SettingsViewController(settingsViewType: .primary)
        //let viewController = SettingsViewController(settingsViewType: .language)
        //let viewController = SettingsViewController(settingsViewType: .version)
        //let viewController = FeedbackViewController()
        let navController = UINavigationController(rootViewController: viewController)
        return navController
    }
    
}
