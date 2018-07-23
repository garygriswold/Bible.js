//
//  LanguageDataSource.swift
//  Settings_iOSApp
//
//  Created by Gary Griswold on 7/23/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit

class LanguageViewDataSource : NSObject, UITableViewDataSource {
    
    let section1Id: String = "cellid"
    let items: [String] = ["Checked items demo",
                           "Various styles demo",
                           "Editable tables demo"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: section1Id)
        cell.textLabel?.text = "Bob"
        cell.showsReorderControl = true
        //cell.showingDeleteConfirmation = true
        
        return cell
    }
    
    //override func string titleForHeader(UITableView tableView, int section) -> String {
    //    return "Items"
    //}
    
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // For more information on why this is necessary, see the Apple docs
        var row = indexPath.row
        
        let cell: UITableViewCell = tableView.DequeueReusableCell(section1Id)
        if (cell == null) {
            // See the styles demo for different UITableViewCellAccessory
            cell = new UITableViewCell(UITableViewCellStyle.Default, section1Id);
            cell.Accessory = UITableViewCellAccessory.DisclosureIndicator;
        }
        
        cell.TextLabel.Text = items[indexPath.Row];
        return cell;
    }
 */
}


