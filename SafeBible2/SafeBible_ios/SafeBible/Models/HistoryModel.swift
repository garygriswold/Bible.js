//
//  HistoryModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/18/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import Foundation
import UIKit

struct History : Equatable {
    let reference: Reference
    let datetime:  CFAbsoluteTime
    
    // Used when creating a History item
    init(reference: Reference) {
        self.reference = reference
        self.datetime = CFAbsoluteTimeGetCurrent()
    }
    
    // Used when retrieving a History item from the Database
    init(reference: Reference, datetime: CFAbsoluteTime) {
        self.reference = reference
        self.datetime = datetime
    }
    
    static func == (lhs: History, rhs: History) -> Bool {
        return lhs.reference == rhs.reference
    }
}

class HistoryHelper {

    @objc static func saveCurrentAtTerminate(note: NSNotification) {
        HistoryModel.shared.changeReference(reference: nil) // Saves _current if necessary
        SettingsDB.shared.cleanUpHistory()
    }
}


struct HistoryModel {
    
    static var shared = HistoryModel()
    private static let SAVE_ON_DELAY = 10.0 // sec
    
    private var _current: History
    private var _history = [History]()
    
    init() {
        self._history = SettingsDB.shared.getHistory()
        if self._history.count < 1 {
            let bibleModel = BibleModel(availableSection: 0, language: nil, selectedOnly: true)
            let bible = bibleModel.getSelectedBible(row: 0)! /// unsafe should be used to for Reference
            let reference = Reference(bibleId: bible.bibleId, bookId: "JHN", chapter: 3)
            self._history.append(History(reference: reference))
            SettingsDB.shared.storeHistory(history: self._history[0])
        }
        self._current = self._history.last!

        NotificationCenter.default.addObserver(HistoryHelper.self,
            selector: #selector(HistoryHelper.saveCurrentAtTerminate(note:)),
            //name: UIApplication.willTerminateNotification,
            name: UIApplication.willResignActiveNotification,
            object: nil)
    }
    
    var currBible: Bible {
        get { return self.current().bible }
    }

    var currBook: Book? { // nil only when TOC data has not arrived from AWS yet.
        get { return self.current().book }
    }

    var currTableContents: TableContentsModel {
        get { return self.current().bible.tableContents! }
    }
    
    var historyCount: Int {
        get { return self._history.count }
    }
    
    func getHistory(row: Int) -> Reference {
        return (row >= 0 && row < self._history.count) ? self._history[row].reference : self._current.reference
    }
    
    func getHistoryItem(row: Int) -> History? {
         return (row >= 0 && row < self._history.count) ? self._history[row] : nil
    }

    mutating func changeBible(bible: Bible) {
        let curr = self.current()
        let ref = Reference(bibleId: bible.bibleId, bookId: curr.bookId, chapter: curr.chapter)
        self.add(reference: ref)
    }
    
    mutating func changeReference(bookId: String, chapter: Int) {
        let curr = self.current()
        let ref = Reference(bibleId: curr.bibleId, bookId: bookId, chapter: chapter)
        self.add(reference: ref)
    }
    
    mutating func changeReference(reference: Reference?) {
        self.add(reference: reference)
    }
    
    mutating func clear() {
        self._history.removeAll()
        SettingsDB.shared.clearHistory()
    }
    
    private mutating func add(reference: Reference?) {
        if CFAbsoluteTimeGetCurrent() - self._current.datetime > HistoryModel.SAVE_ON_DELAY
            && self._current != self._history.last {
            self._history.append(self._current)
            SettingsDB.shared.storeHistory(history: self._current)
        }
        if reference != nil {
            self._current = History(reference: reference!)
        }
    }
    
    func current() -> Reference {
        return self._current.reference
    }
    
    func currentHistory() -> History {
        return self._current
    }
    
    func hasHistory() -> Bool {
        return self._history.count > 0
    }
}
