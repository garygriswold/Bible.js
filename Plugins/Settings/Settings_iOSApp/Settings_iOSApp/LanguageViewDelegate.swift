//
//  LanguageDelegate.swift
//  Settings_iOSApp
//
//  Created by Gary Griswold on 7/23/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit

class LanguageViewDelegate : NSObject, UITableViewDelegate {
    
    private let controller: LanguageViewController
    
    init(controller: LanguageViewController) {
        self.controller = controller
    }
    /*
    public override func RowSelected (tableView: UITableView, indexPath: NSIndexPath) {
    UITableViewController nextController = null;
    
    switch (indexPath.Row)
    {
    case 0:
    nextController = new CheckmarkDemoTableController(UITableViewStyle.Grouped);
    break;
    case 1:
    nextController = new StyleDemoTableController(UITableViewStyle.Grouped);
    break;
    case 2:
    nextController = new EditableTableController(UITableViewStyle.Plain);
    break;
    default:
    break;
    }
    
    if (nextController != null)
    _controller.NavigationController.PushViewController(nextController,true);
    }
    */
}
