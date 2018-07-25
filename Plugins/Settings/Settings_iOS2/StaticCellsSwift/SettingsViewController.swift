//
//  SettingsViewController.swift
//  StaticCellsSwift
//
// http://derpturkey.com/create-a-static-uitableview-without-storyboards/

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    var tableView: UITableView!
    let dataSource = SettingsViewDataSource()
    let delegate = SettingsViewDelegate()

    override func loadView() {
        super.loadView()
 
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.grouped)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
        self.view = self.tableView
 
        // set the view title
        self.title = "Settings"
        
        //self.tableView.setEditing(true, animated: false)
        
        self.tableView.register(VersionCell.self, forCellReuseIdentifier: "currVersion")
    }
}
