//
//  LanguageViewController.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class LanguageViewController: UIViewController {
    
    var tableView: UITableView!
    let dataSource = SettingsViewDataSource(settingsViewType: .language, selectionViewSection: 0)
    let delegate = SettingsViewDelegate(settingsViewType: .language, selectionViewSection: 0)
    
    override func loadView() {
        super.loadView()
        
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.grouped)
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.setEditing(true, animated: false)
        self.view = self.tableView
        
        // set the view title
        self.title = "Languages"
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        // set Top Bar items
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneHandler))
        //self.saveHandler(sender: nil)
        
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "languageCell")
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.delegate
    }
    
    //@objc func editHandler(sender: UIBarButtonItem?) {
    //    self.tableView.setEditing(true, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self,
    //                                                             action: #selector(saveHandler))
    //}
    
    //@objc func saveHandler(sender: UIBarButtonItem?) {
    //    self.tableView.setEditing(false, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
    //                                                             action: #selector(editHandler))
    //}
    
    @objc func doneHandler(sender: UIBarButtonItem?) {
        print("Done button clicked")
    }
}


