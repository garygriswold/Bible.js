//
//  VersionSearchCell.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/26/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//
// https://www.raywenderlich.com/157864/uisearchcontroller-tutorial-getting-started
//

import Foundation
import UIKit

class SearchCell : UITableViewCell {
    
    let searchBar: UISearchBar
    
    init(searchBar: UISearchBar) {
        self.searchBar = searchBar
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: nil)
    }
    required init?(coder: NSCoder) {
        self.searchBar = UISearchBar() // This won't work, because it is not attached to a control
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.searchBar.frame = self.bounds
        //self.searchBar.barTintColor = UIColor(red: 0.179, green: 0.617, blue: 0.785, alpha: 1.0) // #2E9EC9;
        self.searchBar.searchBarStyle = UISearchBarStyle.default // can be (defult or minimal or prominent)
        self.searchBar.showsCancelButton = false
        //self.searchBar.setShowsCancelButton(true, animated: true)
        //self.searchBar.showsBookmarkButton = true // if I want to implement bookmark
        //self.searchBar.showsSearchResultsButton = true // if I want way to see prior results
        self.addSubview(self.searchBar)
    }
    
    static func updateFontSize() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font =
            UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
}

// The above could be moved to Settings View Controller if the search Controller were instantiated there.

