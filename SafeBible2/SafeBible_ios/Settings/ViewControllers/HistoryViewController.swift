//
//  HistoryViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/23/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class HistoryViewController : AppTableViewController, UITableViewDataSource {
    
    static func push(controller: UIViewController?) {
        let histController = HistoryViewController()
        controller?.navigationController?.pushViewController(histController, animated: true)
    }
    
    deinit {
        print("**** deinit HistoryViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("History", comment: "History view page title")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain,
                                                                 target: self,
                                                                 action: #selector(clearHandler))
      
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "historyCell")
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
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
        cell.backgroundColor = AppFont.backgroundColor
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
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
        NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                        object: HistoryModel.shared.current())
        self.navigationController?.popToRootViewController(animated: true)
    }
}

