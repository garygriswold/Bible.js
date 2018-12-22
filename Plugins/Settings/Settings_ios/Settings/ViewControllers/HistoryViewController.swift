//
//  HistoryViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/23/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class HistoryViewController : AppViewController, UITableViewDataSource, UITableViewDelegate {
    
    static func push(controller: UIViewController?) {
        let histController = HistoryViewController()
        controller?.navigationController?.pushViewController(histController, animated: true)
    }
    
    var tableView: UITableView!
    
    deinit {
        print("**** deinit HistoryViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("History", comment: "History view page title")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain,
                                                                 target: self,
                                                                 action: #selector(clearHandler))
        // create Table view
        self.tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        self.tableView.backgroundColor = AppFont.groupTableViewBackground
        self.view.addSubview(self.tableView)
        
        self.tableView.register(LanguageCell.self, forCellReuseIdentifier: "historyCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
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

