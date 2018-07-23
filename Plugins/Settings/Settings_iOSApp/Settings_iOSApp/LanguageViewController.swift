//
//  LanguageViewController.swift
//  Settings_iOSApp
//
//  Created by Gary Griswold on 7/23/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit

/*
class LanguageViewController : UITableViewController {
    
    // Allow us to set the style of the TableView
    //public MainTableController(UITableViewStyle style) : base(style) {
    //}
    
    
    deinit {
        print("****** Deinit LanguageController ******")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let langView = LanguageView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
        langView.dataSource = LanguageViewDataSource()
        langView.delegate = LanguageViewDelegate(controller: self)
        //self.view.addSubview(view)
        //self.view = view
        self.view.addSubview(langView)
    }
}
*/

/*
class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //@IBOutlet
    var tableView: UITableView! = UITableView()
    var items: [String] = ["We", "Heart", "Swift"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
}
 */

class LanguageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
    
        //let myView: UIView = UIView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
        let myView = UIView(frame: CGRect(x: 50, y: 50, width: 200, height:200))
        myView.backgroundColor = UIColor.green
        self.view.addSubview(myView)
    
        let myLabel = UILabel(frame: CGRect(x: 10, y:10, width: 180, height: 50))
        //myLabel.font = UIFont.labelFontSize = 20
        
        myLabel.text = "Example"
        myLabel.textColor = UIColor.darkGray
        myView.addSubview(myLabel)
    }
}
