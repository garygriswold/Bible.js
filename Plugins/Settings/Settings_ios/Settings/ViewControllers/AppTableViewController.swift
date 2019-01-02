//
//  AppTableViewController.swift
//  Settings
//
//  Created by Gary Griswold on 1/2/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class AppTableViewController : AppViewController, UITableViewDelegate {
    
    var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
        
        self.tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        self.tableView.backgroundColor = AppFont.groupTableViewBackground
        self.view.addSubview(self.tableView)
        
        self.tableView.delegate = self
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
}
