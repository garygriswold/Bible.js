//
//  IconViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/27/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class IconViewController : AppTableViewController, UITableViewDataSource {
    
    static func push(controller: UIViewController?) {
        let iconController = IconViewController()
        controller?.navigationController?.pushViewController(iconController, animated: true)
    }
    
    private let icons: [String] = ["cross1", "book1"]
    
    deinit {
        print("**** deinit IconViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Icons", comment: "Icons for home screen")
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "iconViewCell")
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
    }
    
    //
    // Data Source
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let iconName = self.icons[indexPath.row]
        let image = UIImage(named: "www/icons/\(iconName)-Small.png")
        let cell = tableView.dequeueReusableCell(withIdentifier: "iconViewCell", for: indexPath)
        cell.imageView?.image = image
        
        if iconName == UIApplication.shared.alternateIconName {
            cell.accessoryType = .checkmark
        } else if iconName == "cross1" && UIApplication.shared.alternateIconName == nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.backgroundColor = AppFont.backgroundColor
        return cell
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let iconName = self.icons[indexPath.row]
        if iconName != UIApplication.shared.alternateIconName {
            if UIApplication.shared.supportsAlternateIcons {
                UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
                    if let err = error {
                        print("ERROR: IconChangeCell \(err)")
                    }
                })
            }
            tableView.reloadData()
        }
    }
}


