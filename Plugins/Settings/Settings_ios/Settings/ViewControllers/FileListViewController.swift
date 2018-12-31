//
//  FileListViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/30/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class FileListViewController : AppViewController, UITableViewDataSource, UITableViewDelegate {
    
    static func push(controller: UIViewController?) {
        let fileListController = FileListViewController()
        controller?.navigationController?.pushViewController(fileListController, animated: true)
    }
    
    private var tableView: UITableView!
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
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
        //                                                         action: #selector(editHandler))
        
        // create Table view
        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        self.tableView.backgroundColor = AppFont.groupTableViewBackground
        self.view.addSubview(self.tableView)
        
        self.tableView.register(FileCell.self, forCellReuseIdentifier: "fileCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    //override func viewWillAppear(_ animated: Bool) {
    //    super.viewWillAppear(animated)
    //
    //    //self.navigationController?.isToolbarHidden = false
    //}
    
    //override func viewWillDisappear(_ animated: Bool) {
    //    super.viewWillDisappear(animated)
    //
    //    //self.navigationController?.isToolbarHidden = true
    //}
    
    //@objc func editHandler(sender: UIBarButtonItem) {
    //    self.tableView.setEditing(true, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
    //                                                             action: #selector(doneHandler))
    //}
    
    //@objc func doneHandler(sender: UIBarButtonItem) {
    //    self.tableView.setEditing(false, animated: true)
    //    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
    //                                                             action: #selector(editHandler))
    //}
    
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
    
    // Commit data row change to the data source
    //func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
    //               forRowAt indexPath: IndexPath) {
    //    let dbname = self.dbnames.remove(at: indexPath.row)
    //    NotesDB.shared.deleteDB(dbname: dbname)
    //    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    //}
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dbname = self.dbnames[indexPath.row]
        NotesDB.shared.currentDB = dbname
        self.tableView.reloadData()
    }
    
    // Keeps non-editable rows from indenting
    //func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt: IndexPath) -> Bool {
    //    return true
    //}
}

