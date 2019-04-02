//
//  ModelInterface.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

protocol SettingsModel {
 
    var settingsAdapter: SettingsAdapter { get }
    var locales: [Language] { get }
    var selectedCount: Int { get }
    var availableCount: Int { get }
    var filteredCount: Int { get }
    func getSelectedLanguage(row: Int) -> Language?
    func getSelectedBible(row: Int) -> Bible?
    func getAvailableLanguage(row: Int) -> Language?
    func getAvailableBible(section: Int, row: Int) -> Bible?
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell
    func moveSelected(source: Int, destination: Int)
    func moveAvailableToSelected(source: IndexPath, destination: IndexPath, inSearch: Bool)
    func moveSelectedToAvailable(source: IndexPath, destination: IndexPath, inSearch: Bool)
    func findAvailableInsertIndex(selectedIndex: IndexPath) -> IndexPath
    func filterForSearch(searchText: String)
}

