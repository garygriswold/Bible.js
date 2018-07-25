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
        self.view = self.tableView
 
        // set the view title
        self.title = "Settings"
        
        // set Top Bar items
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        self.saveHandler(sender: nil)
        
        self.tableView.register(VersionCell.self, forCellReuseIdentifier: "currVersion")
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
    }
    
    @objc func editHandler(sender: UIBarButtonItem?) {
        self.tableView.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                                                 action: #selector(saveHandler))
    }
    
    @objc func saveHandler(sender: UIBarButtonItem?) {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
    }
    
    @objc func doneHandler(sender: UIBarButtonItem?) {
        print("Done button clicked")
    }
}


// why does auto rotation not work
