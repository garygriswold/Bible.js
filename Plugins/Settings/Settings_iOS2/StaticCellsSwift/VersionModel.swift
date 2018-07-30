//
//  VersionModel.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class VersionModel : SettingsModelInterface {
    
    private var versions = [Version]() // temporary, I think
    private var sequence = [String]()
    private var selected = [Version]()
    private var available = [Version]()
    private var filtered = [Version]()
    
    init() {
        fill()
    }
    
    func fill() {
        sequence.append("ESV")
        sequence.append("ERV-CMN")
        sequence.append("ERV-ARB")
        
        var versSelectedMap = [String : Bool]()
        for vers in sequence {
            versSelectedMap[vers] = true
        }
        
        versions.append(Version(versionCode: "KJV", languageCode: "ENG",
                                versionName: "King James Version",
                                englishName: "King James Version",
                                organizationId: "PD", organizationName: "Public Domain",
                                copyright: ""))
        versions.append(Version(versionCode: "WEB", languageCode: "ENG",
                                versionName: "World English Bible",
                                englishName: "World English Bible",
                                organizationId: "PD", organizationName: "Public Domain",
                                copyright: ""))
        versions.append(Version(versionCode: "ESV", languageCode: "ENG",
                                versionName: "English Standard Version",
                                englishName: "English Standard Version",
                                organizationId: "GP", organizationName: "Gospel Folio Press",
                                copyright: ""))
        versions.append(Version(versionCode: "NIV", languageCode: "ENG",
                                versionName: "New International Version",
                                englishName: "New International Version",
                                organizationId: "HAR", organizationName: "Harold Publishing",
                                copyright: ""))
        versions.append(Version(versionCode: "ERV-ENG", languageCode: "ENG",
                                versionName: "Easy Read Version",
                                englishName: "Easy Read Version",
                                organizationId: "BLI", organizationName: "Bible League International",
                                copyright: ""))
        versions.append(Version(versionCode: "ERV-CMN", languageCode: "CMN",
                                versionName: "圣经–普通话本",
                                englishName: "Chinese Union Version",
                                organizationId: "BLI", organizationName: "Bible League International",
                                copyright: "2016"))
        versions.append(Version(versionCode: "ERV-ARB", languageCode: "ARB",
                                versionName: "الكتاب المقدس ترجمة فان دايك",
                                englishName: "Van Dycke Bible",
                                organizationId: "BLI", organizationName: "Bible League International",
                                copyright: ""))
        
        for vers in versions {
            let versCode = vers.versionCode
            if versSelectedMap[versCode] == nil {
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
    
    func selectedCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "versionCell", for: indexPath)
        let version = selected[indexPath.row]
        cell.textLabel?.text = "\(version.versionCode), \(version.versionName)"
        cell.detailTextLabel?.text = "\(version.organizationName)"
        cell.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
        return cell
    }
    
    func availableCell(tableView: UITableView, indexPath: IndexPath, inSearch: Bool) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "versionCell", for: indexPath)
        let version = (inSearch) ? filtered[indexPath.row] : available[indexPath.row]
        cell.textLabel?.text = "\(version.versionCode), \(version.versionName)"
        cell.detailTextLabel?.text = "\(version.organizationName)"
        cell.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
        return cell
    }
    
    func moveSelected(source: Int, destination: Int) {
        let version = self.selected[source]
        self.selected.remove(at: source)
        self.selected.insert(version, at: destination)
    }
    
    func moveAvailableToSelected(source: Int, destination: Int, inSearch: Bool) {
        var version: Version
        if inSearch {
            version = self.filtered[source]
            guard let availableIndex = self.available.index(of: version) else {
                print("Item in filtered not found in available? \(version.versionCode)")
                return
            }
            self.filtered.remove(at: source)
            self.available.remove(at: availableIndex)
        } else {
            version = self.available[source]
            self.available.remove(at: source)
        }
        self.selected.insert(version, at: destination)
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
            if vers.versionName.lowercased().contains(searchFor) ||
                vers.versionCode.lowercased().contains(searchFor) {
                self.filtered.append(vers)
            }
        }
    }
}
