//
//  MenuViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 1/19/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class MenuViewController: AppTableViewController, UITableViewDataSource {

    static func push(controller: UIViewController?) {
        let menuController = MenuViewController()
        controller?.navigationController?.pushViewController(menuController, animated: true)
    }
    
    private var textSizeSliderCell: TextSizeSliderCell!
    private var textHeightSliderCell: TextHeightSliderCell!
    private let nightSwitch: UISwitch
    private let verseSwitch: UISwitch
    
    init() {
        self.nightSwitch = UISwitch(frame: .zero)
        self.verseSwitch = UISwitch(frame: .zero)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("MenuViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit MenuViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.textSizeSliderCell = TextSizeSliderCell(controller: self, style: .default, reuseIdentifier: nil)
        self.textHeightSliderCell = TextHeightSliderCell(controller: self, style: .default, reuseIdentifier: nil)
        
        self.navigationItem.title = NSLocalizedString("Menu", comment: "Menu view page title")

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "otherCell")
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
    }
    
    //
    // Data Source
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 4
        case 2: return 2
        case 3: return (UserMessageController.isAvailable()) ? 4 : 3
        default: fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let tocText = NSLocalizedString("Table of Contents", comment: "Table of Contents Title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: tocText,
                                        accessory: true, icon: "ios-keypad.png")
            case 1:
                let histText = NSLocalizedString("History", comment: "History Cell Title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: histText,
                                        accessory: true, icon: "ios-previous.png")
            case 2:
                let notesText = NSLocalizedString("Notes", comment: "Notes Cell Title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: notesText,
                                        accessory: true, icon: "ios-new.png")
            case 3:
                let videoText = NSLocalizedString("Videos", comment: "Videos Cell Title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: videoText,
                                        accessory: true, icon: "ios-films.png")
            default: fatalError("Unknown row \(indexPath.row) in section 0")
            }
        case 1:
            switch indexPath.row {
            case 0:
                return self.textSizeSliderCell
            case 1:
                return self.textHeightSliderCell
            case 2:
                let nightText = NSLocalizedString("Night Time", comment: "Clickable cell title")
                let nightCell = self.genericCell(view: tableView, indexPath: indexPath, title: nightText,
                                                 accessory: false, icon: "wea-moon.png")
                self.nightSwitch.setOn(AppFont.nightMode, animated: false)
                self.nightSwitch.addTarget(self, action: #selector(nightSwitchHandler),
                                           for: .valueChanged)
                nightCell.accessoryView = self.nightSwitch
                return nightCell
            case 3:
                let verseText = NSLocalizedString("Verse Numbers", comment: "Clickable cell title")
                let verseCell = self.genericCell(view: tableView, indexPath: indexPath, title: verseText,
                                                 accessory: false, icon: "typ-bullets-numbers.png")
                self.verseSwitch.setOn(AppFont.verseNumbers, animated: false)
                self.verseSwitch.addTarget(self, action: #selector(verseSwitchHandler),
                                           for: .valueChanged)
                verseCell.accessoryView = self.verseSwitch
                return verseCell
            default: fatalError("Unknown row \(indexPath.row) in section 1")
            }
        case 2:
            switch indexPath.row {
            case 0:
                let bibleText = NSLocalizedString("More Bibles", comment: "Clickable cell title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: bibleText,
                                        accessory: true, icon: "cel-bible.png")
            case 1:
                let langText = NSLocalizedString("More Languages", comment: "Clickable cell title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: langText,
                                        accessory: true, icon: "ios-world-times.png")
            default: fatalError("Unknown row \(indexPath.row) in section 2")
            }
        case 3:
            switch indexPath.row {
            case 0:
                let reviewText = NSLocalizedString("Write A Review", comment: "Clickable cell title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: reviewText,
                                        accessory: true, icon: "ios-new.png")
            case 1:
                let commentText = NSLocalizedString("Send Us Comments", comment: "Clickable cell title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: commentText,
                                        accessory: true, icon: "ios-reply.png")
            case 2:
                let privText = NSLocalizedString("Privacy Policy", comment: "Privacy Policy cell title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: privText,
                                        accessory: true, icon: "sec-shield-diagonal.png")
            case 3:
                let shareText = NSLocalizedString("Share SafeBible", comment: "Clickable cell title")
                return self.genericCell(view: tableView, indexPath: indexPath, title: shareText,
                                        accessory: true, icon: "ios-upload.png")
            default: fatalError("Unknown row \(indexPath.row) in section 3")
            }
        default:
            fatalError("Unknown section \(indexPath.section) ")
        }
    }
    
    @objc func nightSwitchHandler(sender: UISwitch) {
        AppFont.nightMode = sender.isOn
        if let cell = sender.superview as? UITableViewCell {
            if let table = cell.superview as? UITableView {
                table.reloadData()
                var vu: UIView? = table
                while(vu != nil) {
                    vu!.backgroundColor = AppFont.backgroundColor
                    vu = vu!.superview
                }
            }
        }
        if let navBar = self.navigationController?.navigationBar {
            // Controls Navbar background color
            navBar.barTintColor = AppFont.backgroundColor
            // Controls Navbar text color
            navBar.barStyle = (AppFont.nightMode) ? .black : .default
        }
        ReaderViewQueue.shared.updateCSS(css: DynamicCSS.shared.nightMode.genRule())
    }
    
    @objc func verseSwitchHandler(sender: UISwitch) {
        AppFont.verseNumbers = sender.isOn
        if HistoryModel.shared.current().isShortsands {
             ReaderViewQueue.shared.updateCSS(css: DynamicCSS.shared.verseNumbersSS.genRule())
        } else {
             ReaderViewQueue.shared.updateCSS(css: DynamicCSS.shared.verseNumbersDBP.genRule())
        }
    }
    
    private func genericCell(view: UITableView, indexPath: IndexPath, title: String,
                             accessory: Bool, icon: String) -> UITableViewCell {
        let cell = view.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
        cell.textLabel?.text = title
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.textColor = AppFont.textColor
        cell.backgroundColor = AppFont.backgroundColor
        cell.accessoryView = nil
        var image = UIImage(named: icon)
        image = image?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = UIColor.gray
        cell.imageView?.image = image
        if accessory {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        return cell
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                TOCBooksViewController.push(controller: self)
            case 1:
                HistoryViewController.push(controller: self)
            case 2:
                NotesListViewController.push(controller: self)
            case 3:
                let bible = HistoryModel.shared.currBible
                VideoViewController.push(iso3: bible.iso3, controller: self)
            default: fatalError("Unknown row \(indexPath.row) in section 0")
            }
        case 1:
            print("Section 1 Font Size Widget.  It is not selectable.")
        case 2:
            switch indexPath.row {
            case 0:
                BibleListViewController.push(settingsViewType: .bible, controller: self, language: nil)
            case 1:
                LanguageListViewController.push(controller: self)
            default: fatalError("Unknown row \(indexPath.row) in section 1")
            }
        case 3:
            switch indexPath.row {
            case 0:
                guard let reviewURL = URL(string: "https://itunes.apple.com/app/id1073396349?action=write-review")
                    else { fatalError("Expected a valid URL") }
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            case 1:
                FeedbackViewController.push(controller: self)
            case 2:
                InfoPageController.push(controller: self)
            case 3:
                UserMessageController.present(controller: self)
            default:
                print("Unknown row \(indexPath.row) in section 0")
            }
        default:
            fatalError("Unknown section \(indexPath.section)")
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let heading = titleForHeaderInSection(section: section) {
            let font = AppFont.sansSerif(style: .subheadline)
            let label = UILabel()
            label.backgroundColor = AppFont.groupTableViewBackground
            label.font = font
            label.textAlignment = .center
            label.textColor = UIColor.darkGray
            label.text = heading
            return label
        } else {
            let label = UILabel()
            label.backgroundColor = AppFont.groupTableViewBackground
            return label
        }
    }
    
    private func titleForHeaderInSection(section: Int) -> String? {
        switch section {
        case 0: return nil
        case 1: return nil
        case 2: return NSLocalizedString("Bibles", comment: "Section heading for User selected Bibles")
        case 3: return NSLocalizedString("About", comment: "Section heading for About")
        default: fatalError("Unknown section \(section)")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let font = AppFont.sansSerif(style: .subheadline)
        if section == 0 {
            return 1.0 * font.lineHeight
        }
        else if section <= 1 {
            return 1.5 * font.lineHeight
        }
        else {
            return 3 * font.lineHeight
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.4)
        let label = UILabel(frame: rect)
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.4
    }
}
