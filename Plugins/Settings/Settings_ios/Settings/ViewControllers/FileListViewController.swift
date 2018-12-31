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
    private var files: [String]!
    
    deinit {
        print("**** deinit FileListViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.files = NotesDB.shared.listDB()
        
        let notebooks = NSLocalizedString("Notebooks", comment: "Notebook files in list")
        self.navigationItem.title = notebooks
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
        
        // create Table view
        self.tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        self.tableView.backgroundColor = AppFont.groupTableViewBackground
        self.view.addSubview(self.tableView)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.tableView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.navigationController?.isToolbarHidden = true
    }
    
    @objc func editHandler(sender: UIBarButtonItem) {
        self.tableView.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                 action: #selector(doneHandler))
    }
    
    @objc func doneHandler(sender: UIBarButtonItem) {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
    }
    
    //
    // Data Source
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = self.files[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
        cell.backgroundColor = AppFont.backgroundColor
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
        cell.textLabel?.text = file
        //cell.selectionStyle = .default
        return cell
    }
    
    // Return true for each row that can be edited
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Commit data row change to the data source
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        //let file = self.files[indexPath.row]
        let file = self.files.remove(at: indexPath.row)
        NotesDB.shared.deleteDB(dbname: file) // or should it be entire filename
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let file = self.files[indexPath.row]
        //NotesDB.shared.openDB(dbname: file)
        self.navigationController?.popViewController(animated: true)
    }
    // Identifies Add and Delete Rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    // Keeps non-editable rows from indenting
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt: IndexPath) -> Bool {
        return true
    }
}

