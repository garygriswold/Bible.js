//
//  SearchViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/15/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//
import Foundation
import UIKit

class ConcordanceViewController: AppTableViewController, UITableViewDataSource {
    
    static let VIEW_SEARCHES = 0
    static let VIEW_LAST_SEARCH = 1
   
    static func push(controller: UIViewController?) {
        let searchController = ConcordanceViewController()
        controller?.navigationController?.pushViewController(searchController, animated: true)
    }
 
    private var searchController: ConcordanceSearchController!
    var typeControl: UISegmentedControl!

    init() {
        super.init(nibName: nil, bundle: nil)
        self.searchController = ConcordanceSearchController(controller: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ConcordanceViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit ConcordanceViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Word Search", comment: "Title of Search page")
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "concordanceSearch")
        self.tableView.register(ConcordanceResultCell.self, forCellReuseIdentifier: "concordanceResult")
        
        // prevent searchBar from holding onto focus
        self.definesPresentationContext = true
        
        self.tableView.dataSource = self
        
        self.createToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = false
        
        self.tableView.frame = self.view.bounds
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 1.0))
        self.tableView.tableHeaderView = label
        
        self.tableView.dataSource = self
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.searchController.viewAppears()
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardInfo: Dictionary = note.userInfo {
            if let keyboardRect: CGRect = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = keyboardRect.minY
                let bounds = self.view.bounds
                self.tableView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: keyboardTop)
            }
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.tableView.frame = self.view.bounds
    }
    
    private func createToolbar() {
        if let nav = self.navigationController {
            
            nav.toolbar.isTranslucent = false
            nav.toolbar.barTintColor = AppFont.backgroundColor
        }
        let history = NSLocalizedString("Searches", comment: "Concordance search history")
        let results = NSLocalizedString("Last Search", comment: "Result of last concordance search")
        self.typeControl = UISegmentedControl(items: [history, results])
        self.typeControl.selectedSegmentIndex = ConcordanceViewController.VIEW_LAST_SEARCH
        self.typeControl.addTarget(self, action: #selector(viewTypeHandler), for: .valueChanged)
        
        let typeCtrl = UIBarButtonItem(customView: typeControl)
        self.setToolbarItems([typeCtrl], animated: true)
    }
    
    @objc func viewTypeHandler(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if index == ConcordanceViewController.VIEW_LAST_SEARCH {
            self.searchController.updateSearchBar()
        } else {
            ConcordanceModel.shared.clearSearch()
            self.searchController.clearSearchBar()
        }
        self.typeControl.selectedSegmentIndex = index
        self.tableView.reloadData()
    }
    
    //
    // DataSource
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let concordance = ConcordanceModel.shared
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            print("table view results count \(concordance.results.count)")
            return concordance.results.count
        } else {
            print("table view history count \(concordance.historyCount)")
            return concordance.historyCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            return showLastResult(indexPath: indexPath)
        } else {
            return showSearchHistory(indexPath: indexPath)
        }
    }
    
    private func showSearchHistory(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "concordanceSearch", for: indexPath)
        cell.contentView.backgroundColor = AppFont.backgroundColor
        cell.textLabel?.textColor = AppFont.textColor
        cell.textLabel?.text = ConcordanceModel.shared.getHistory(row: indexPath.row)
        return cell
    }
    
    private func showLastResult(indexPath: IndexPath) -> ConcordanceResultCell {
        let concordance = ConcordanceModel.shared
        let wordRef = concordance.results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "concordanceResult", for: indexPath) as! ConcordanceResultCell
        cell.contentView.backgroundColor = AppFont.backgroundColor
        
        cell.title.textColor = AppFont.textColor
        cell.verse.textColor = AppFont.textColor
        
        let bible = HistoryModel.shared.currBible
        let reference = Reference(bibleId: bible.bibleId, bookId: wordRef.bookId,
                                  chapter: Int(wordRef.chapter))
        cell.title.text = reference.description(verse: wordRef.verse)
        cell.verse.attributedText = self.format(bible: bible, wordRef: wordRef)

        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func format(bible: Bible, wordRef: WordRef) -> NSMutableAttributedString? {
        let pointSize = AppFont.serif(style: .body).pointSize * 0.95
        if let verseStr = BibleDB.shared.selectVerse(bible: bible, wordRef: wordRef) {
            let verse = NSMutableAttributedString(string: verseStr)
            let ranges = self.findRanges(string: verseStr, wordPositions: wordRef.wordPositions!)
            for range in ranges {
                verse.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: pointSize), range: range)
            }
            return verse
        } else {
            return nil
        }
    }
    
    private func findRanges(string: String, wordPositions: WordPositions) -> [NSRange] {
        var wordPositions = self.sequencePositions(wordPositions: wordPositions)
        var ranges = [NSRange]()
        var search = wordPositions.remove(at: 0)
        let chars = Array(string)
        var insideWord = false
        var wordStart = 0
        var wordCount: UInt8 = 0
        for index in 0..<chars.count {
            let char = chars[index]
            if char == " " || char == "\t" || char == "\n" || char == "\r" {
                if wordCount == search && insideWord {
                    ranges.append(NSRange(location: wordStart, length: index - wordStart))
                    if wordPositions.count > 0 {
                        search = wordPositions.remove(at: 0)
                    } else {
                        return ranges
                    }
                }
                insideWord = false
            } else if !char.isPunctuation {
                if !insideWord {
                    insideWord = true
                    wordStart = index
                    wordCount += 1
                }
            }
        }
        if wordCount == search && insideWord {
            ranges.append(NSRange(location: wordStart, length: chars.count - wordStart))
        }
        return ranges
    }
    
    private func sequencePositions(wordPositions: WordPositions) -> [UInt8] {
        var result = [UInt8]()
        for index in 0..<wordPositions.numWords {
            result += wordPositions.positions[index]
        }
        return result.sorted()
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.typeControl.selectedSegmentIndex == ConcordanceViewController.VIEW_LAST_SEARCH {
            let wordRef = ConcordanceModel.shared.results[indexPath.row]
            HistoryModel.shared.changeReference(bookId: wordRef.bookId, chapter: Int(wordRef.chapter))
            NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                            object: HistoryModel.shared.current())
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            let words = ConcordanceModel.shared.getHistoryWords(row: indexPath.row)
            let bible = HistoryModel.shared.currBible
            let results = ConcordanceModel.shared.search(bible: bible, words: words)
            self.searchController.updateSearchBar() // The placement of this is critical
            self.typeControl.selectedSegmentIndex = ConcordanceViewController.VIEW_LAST_SEARCH
            tableView.reloadData()
        }
    }
}

class ConcordanceResultCell : UITableViewCell {
    let title = UILabel()
    let verse = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.title.font = AppFont.sansSerif(style: .subheadline)
        self.contentView.addSubview(self.title)
        
        self.verse.numberOfLines = 0
        self.verse.font = AppFont.serif(style: .body)
        self.contentView.addSubview(self.verse)
        
        let inset = self.contentView.frame.width * 0.05
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        
        self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: inset).isActive = true
        self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: inset).isActive = true
        
        self.verse.translatesAutoresizingMaskIntoConstraints = false
        
        self.verse.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: inset / 2.0).isActive = true
        self.verse.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: inset).isActive = true
        self.verse.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -inset).isActive = true
        self.verse.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -inset).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("ConcordanceResultCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit ConcordanceResultCell ******")
    }
}
