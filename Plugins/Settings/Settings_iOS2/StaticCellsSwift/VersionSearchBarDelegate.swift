//
//  VersionSearchBarDelegate.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/26/18.
//  Copyright © 2018 Short Sands, LLC All rights reserved.
//
// https://www.raywenderlich.com/157864/uisearchcontroller-tutorial-getting-started
//

import Foundation
import UIKit

class VersionSearchBarDelegate : NSObject, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange: String) {
        print("SearchBar.textDidChange")
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("SearchBar.shouldBeginEditing?")
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("SearchBar.didBeginEditing")
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        print("SearchBar.shouldEndEditing?")
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("SearchBar.didEndEditing")
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("SearchBar.bookmarkButtonClicked")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("SearchBar.cancelButtonClicked")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SearchBar.searchButtonClicked")
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("SearchBar.resultsListButtonClicked")
    }
    
}
