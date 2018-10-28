//
//  HistoryViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/23/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class HistoryViewController : AppViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    
    deinit {
        print("**** deinit HistoryViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        // create Table view
        self.tableView = UITableView(frame: UIScreen.main.bounds, style: UITableView.Style.plain)
        self.view.addSubview(self.tableView)
        
        self.navigationItem.title = NSLocalizedString("History", comment: "History view page title")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain,
                                                                 target: self,
                                                                 action: #selector(clearHandler))
        
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "historyCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @objc func clearHandler(sender: UIBarButtonItem) {
        HistoryModel.shared.clear()
        self.tableView.reloadData()
    }
    
    //
    // Data Source
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HistoryModel.shared.historyCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = HistoryModel.shared.historyCount - indexPath.row - 1
        let reference = HistoryModel.shared.getHistory(row: index)
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        cell.textLabel?.text = reference.description()
        cell.detailTextLabel?.text = reference.bibleName
        cell.selectionStyle = .default
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }

    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = HistoryModel.shared.historyCount - indexPath.row - 1
        let ref = HistoryModel.shared.getHistory(row: index)
        tableView.deselectRow(at: indexPath, animated: true)
        HistoryModel.shared.changeReference(reference: ref)
        self.navigationController?.popToRootViewController(animated: true)
    }
}

