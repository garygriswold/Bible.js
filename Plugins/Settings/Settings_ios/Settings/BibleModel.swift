//
//  VersionModel.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class BibleModel : SettingsModelInterface {
    
    private var bibles = [Bible]() // temporary, I think
    private var sequence = [String]()
    private var selected = [Bible]()
    private var available = [Bible]()
    private var filtered = [Bible]()
    
    init() {
        fill()
    }
    
    func fill() {
        sequence.append("ESV")
        sequence.append("ERV-CMN")
        sequence.append("ERV-ARB")
        
        var bibleSelectedMap = [String : Bool]()
        for vers in sequence {
            bibleSelectedMap[vers] = true
        }
        
        bibles.append(Bible(bibleId: "ENGKJV", abbr: "KJV", iso: "eng",
                                name: "King James Version",
                                vname: "King James Version"))
        bibles.append(Bible(bibleId: "ENGWEB", abbr: "WEB", iso: "eng",
                                name: "World English Bible",
                                vname: "World English Bible"))
        bibles.append(Bible(bibleId: "ENGESV", abbr: "ESV", iso: "eng",
                                name: "English Standard Version",
                                vname: "English Standard Version"))
        bibles.append(Bible(bibleId: "ENGNIV", abbr: "NIV", iso: "eng",
                                name: "New International Version",
                                vname: "New International Version"))
        bibles.append(Bible(bibleId: "ERV-ENG", abbr: "ERV", iso: "eng",
                                name: "Easy Read Version",
                                vname: "Easy Read Version"))
        bibles.append(Bible(bibleId: "ERV-CMN", abbr: "ERV", iso: "cmn",
                                name: "圣经–普通话本",
                                vname: "Chinese Union Version"))
        bibles.append(Bible(bibleId: "ERV-ARB", abbr: "ERV", iso: "arb",
                                name: "الكتاب المقدس ترجمة فان دايك",
                                vname: "Van Dycke Bible"))
        
        for vers in bibles {
            let bibleId = vers.bibleId
            if bibleSelectedMap[bibleId] == nil {
                available.append(vers)
            } else {
                selected.append(vers)
            }
        }
    }

    var selectedCount: Int {
        get { return selected.count }
    }
    
    var availableCount: Int {
        get { return available.count }
    }
    
    var filteredCount: Int {
        get { return filtered.count }
    }
    
    func getSelectedBible(row: Int) -> Bible? {
        return (row >= 0 && row < selected.count) ? selected[row] : nil
    }
    func getSelectedLanguage(row: Int) -> Language? {
        return nil
    }
    func getAvailableBible(row: Int) -> Bible? {
        return (row >= 0 && row < available.count) ? available[row] : nil
    }
    func getAvailableLanguage(row: Int) -> Language? {
        return nil
    }
    
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bibleCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let bible = selected[indexPath.row]
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bibleCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .body)
        cell.detailTextLabel?.font = AppFont.sansSerif(style: .footnote)
        let bible = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        cell.textLabel?.text = bible.name
        cell.detailTextLabel?.text = bible.abbr
        cell.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let version = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(version, at: destination)
    }
    
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool) {
        var bible: Bible
        if inSearch {
            bible = self.filtered[source]
            guard let availableIndex = self.available.index(of: bible) else {
                print("Item in filtered not found in available? \(bible.bibleId)")
                return
            }
            self.filtered.remove(at: source)
            self.available.remove(at: availableIndex)
        } else {
            bible = self.available[source]
            self.available.remove(at: source)
        }
        self.selected.insert(bible, at: destination)
    }
    
    func moveSelectedToAvailable(source: Int, destination: Int, inSearch: Bool) {
        let version = self.selected[source]
        self.selected.remove(at: source)
        self.available.insert(version, at: destination)
        if inSearch {
            self.filtered.insert(version, at: destination)
        }
    }
    
    func filterForSearch(searchText: String) {
        print("****** INSIDE FILTER CONTENT FOR SEARCH ******")
        let searchFor = searchText.lowercased()
        self.filtered.removeAll()
        for vers in available {
            if vers.name.lowercased().contains(searchFor) ||
                vers.abbr.lowercased().contains(searchFor) {
                self.filtered.append(vers)
            }
        }
    }
}
