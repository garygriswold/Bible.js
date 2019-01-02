//
//  FileListViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/30/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class FileListViewController : AppTableViewController, UITableViewDataSource {
    
    static func push(controller: UIViewController?) {
        let fileListController = FileListViewController()
        controller?.navigationController?.pushViewController(fileListController, animated: true)
    }
    
    private var dbnames: [String]!
    private var files: [String: URLResourceValues]!
    
    deinit {
        print("**** deinit FileListViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.files = NotesDB.shared.listDB()
        self.dbnames = self.files.keys.sorted()
        
        let notebooks = NSLocalizedString("Notebooks", comment: "Notebook files in list")
        self.navigationItem.title = notebooks

        self.tableView.register(FileCell.self, forCellReuseIdentifier: "fileCell")
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
        return self.dbnames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dbname = self.dbnames[indexPath.row]
        let file = self.files[dbname]
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
        cell.textLabel?.text = dbname
        if let addedDate = file?.addedToDirectoryDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            cell.detailTextLabel!.text = formatter.string(from: addedDate)
            cell.detailTextLabel!.font = AppFont.sansSerif(style: .caption1)
            cell.detailTextLabel!.textColor = AppFont.textColor
        }
        if NotesDB.shared.currentDB == dbname {
            let alpha = AppFont.nightMode ? 0.2 : 1.0
            cell.backgroundColor = UIColor(red: 0.89, green: 0.98, blue: 0.96, alpha: CGFloat(alpha))
        } else {
            cell.backgroundColor = AppFont.backgroundColor
        }
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
        let dbname = self.dbnames[indexPath.row]
        NotesDB.shared.currentDB = dbname
        tableView.reloadData()
    }
}

