//
//  ConcordanceModel.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/8/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import Foundation

struct WordRef : Equatable, Hashable {
    
    private static let delims = CharacterSet(charactersIn: ":;")
    
    let bookId: String
    let chapter: UInt8
    let verse: UInt8
    var positions: [UInt8]
    var wordPositions: WordPositions!
    
    init(reference: String) {
        let parts = reference.components(separatedBy: WordRef.delims)
        self.bookId = parts[0]
        self.chapter = UInt8(parts[1])!
        self.verse = UInt8(parts[2])!
        self.positions = [UInt8(parts[3])!]
    }
    
    var reference: String {
        return "\(self.bookId):\(self.chapter):\(self.verse)"
    }
    
    mutating func add(position: UInt8) {
        self.positions.append(position)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.bookId)
        hasher.combine(self.chapter)
        hasher.combine(self.verse)
    }
    
    static func == (lhs: WordRef, rhs: WordRef) -> Bool {
        return lhs.bookId == rhs.bookId && lhs.chapter == rhs.chapter && lhs.verse == rhs.verse
    }
}

struct WordPositions {
    var positions: [[UInt8]]
    
    init(numWords: Int) {
        self.positions = Array(repeating: [UInt8](), count: numWords)
    }
    
    var numWords: Int {
        return self.positions.count
    }
    
    mutating func addWord(word: Int, positions: [UInt8]) {
        self.positions[word] = positions
    }
    
    mutating func addReference(positions: [UInt8]) {
        for wordIndex in 0..<positions.count {
            self.positions[wordIndex].append(positions[wordIndex])
        }
    }
    
    mutating func addIfNewReference(positions: [UInt8]) {
        for wordIndex in 0..<positions.count {
            let lastValue = self.positions[wordIndex].last
            if lastValue == nil || lastValue != positions[wordIndex] {
                self.positions[wordIndex].append(positions[wordIndex])
            }
        }
    }
}

struct ConcordanceModel {
    
    static var shared = ConcordanceModel()
    
    // These are the exact characters used to delimit words used by the concordance builder program
    // See BibleApp/Library/ConcordanceBuilder.js line 53
    static let delims = CharacterSet(charactersIn:
        " \t\t\r-\u{2010}\u{2011}\u{2012}\u{2013}\u{2014}\u{2015}\u{2043}\u{058A}")
    
    var results: [WordRef]
    private var fullHistory: [String]
    private var history: [String]
    
    private init() {
        print("****** Init ConcordanceModel ******")
        self.fullHistory = SettingsDB.shared.getConcordanceHistory()
        self.history = self.fullHistory
        self.results = [WordRef]()
    }
    
    
    //var concordance = ConcordanceModel.shared
    //let result = concordance.search(bible: reference.bible, words: ["abide"])
    //let result = concordance.search1(bible: reference.bible, words: ["the", "and", "a"])
    //let result = concordance.search3(bible: reference.bible, words: ["the", "and", "a"])
    //let result = concordance.search4(bible: reference.bible, words: ["actions"])//,
    //let result = concordance.search2(bible: reference.bible, words: ["tent", "having"])
    //let result = concordance.search2(bible: reference.bible, words: ["immediately", "it", "sprang"])
    //let result = concordance.search2(bible: reference.bible, words: ["and", "the"])
    //let resultSet = Set(result)
    //print(resultSet.count)
    //print(result.count)
    //print(result)
    
    var historyCount: Int {
        return self.history.count
    }
    
    var historyCurrent: String {
        return (history.last != nil) ? history.last! : ""
    }
    
    func getHistory(row: Int) -> String {
        return self.history[self.history.count - row - 1]
    }
    
    mutating func setHistory(search: String) {
        if let index = self.fullHistory.index(of: search) {
            self.fullHistory.remove(at: index)
        }
        self.fullHistory.append(search)
        self.history = self.fullHistory
        let measure = Measurement()
        SettingsDB.shared.setConcordanceHistory(history: self.fullHistory)
        measure.duration(location: "setConcordanceHistory")
    }
    
    mutating func filterForSearch(searchText: String) {
        let searchFor = searchText.lowercased()
        self.history = self.fullHistory.filter { $0.lowercased().hasPrefix(searchFor) }
    }
    
    mutating func clearSearch() {
        self.history = self.fullHistory
    }
    
    mutating func search(bible: Bible, search: String) -> [WordRef] {
        self.setHistory(search: search)
        if bible.language.iso == "zh" || bible.language.iso == "th" {
            let chars:[Character] = Array(search)
            let words:[String] = chars.map { String($0) }
            self.results = self.search2(bible: bible, words: words)
        } else {
            let search2 = search.lowercased()
            let words: [String] = search2.components(separatedBy: ConcordanceModel.delims)
            self.results = self.search3(bible: bible, words: words)
        }
        return self.results
    }
    
    /**
    * This method searches for all verses that contain all of the words entered.
    * It does not consider the position of the words, but it keeps track of each occurrance.
    */
    func search1(bible: Bible, words: [String]) -> [WordRef] {
        var result = [WordRef]()
        let measure = Measurement()
        if words.count == 0 {
            return result
        }
        let refLists: [[WordRef]] = BibleDB.shared.selectRefList3(bible: bible, words: words)
        if refLists.count != words.count {
            return result
        }
        measure.duration(location: "database select complete")
        // Prepare second to nth word
        var mapList = [[WordRef: [UInt8]]]()
        for index in 1..<refLists.count {
            var map = [WordRef: [UInt8]]()
            for wordRef in refLists[index] {
                map[wordRef] = wordRef.positions
            }
            mapList.append(map)
        }
        measure.duration(location: "build hashtables")
        let firstList = refLists[0]
        for index in 0..<firstList.count {
            var wordRef: WordRef = firstList[index]
            let wordPos = presentInAllSets(mapList: mapList, wordRef: wordRef)
            if wordPos != nil {
                wordRef.wordPositions = wordPos
                result.append(wordRef)
            }
        }
        measure.final(location: "search1")
        return result
    }
    
    private func presentInAllSets(mapList: [[WordRef: [UInt8]]], wordRef: WordRef) -> WordPositions? {
        var result = WordPositions(numWords: (mapList.count + 1))
        result.addWord(word: 0, positions: wordRef.positions)
        for index in 0..<mapList.count {
            let map = mapList[index]
            let found: [UInt8]? = map[wordRef]
            if found != nil {
                result.addWord(word: (index + 1), positions: found!)
            } else {
                return nil
            }
        }
        return result
    }

    /**
    * This method searches for all of the words entered, but only returns references
    * where they are entered in the consequtive order of the search parameters.
    * This search method should be used for chinese
    */
    func search2(bible: Bible, words: [String]) -> [WordRef] {
        var finalResult = [WordRef]()
        let results1: [WordRef] = self.search1(bible: bible, words: words)
        if results1.count == 0 {
            return finalResult
        }
        for index in 0..<results1.count {
            var wordRef = results1[index]
            let updatedPostions = self.matchToEachReference2(wordPositions: wordRef.wordPositions!)
            if updatedPostions.positions[0].count > 0 {
                wordRef.wordPositions = updatedPostions
                finalResult.append(wordRef)
            }
        }
        return finalResult
    }
    
    private func matchToEachReference2(wordPositions: WordPositions) -> WordPositions {
        var updatedPositions = WordPositions(numWords: wordPositions.numWords)
        let firstWordPositions: [UInt8] = wordPositions.positions[0]
        for index in 0..<firstWordPositions.count {
            let matches: [UInt8]? = self.matchToEachWord2(wordPositions: wordPositions, index: index)
            if matches != nil {
                updatedPositions.addReference(positions: matches!)
            }
        }
        return updatedPositions
    }
    
    private func matchToEachWord2(wordPositions: WordPositions, index: Int) -> [UInt8]? {
        var updatedPositions: [UInt8] = Array(repeating: 0, count: wordPositions.numWords)
        var nextPosition: UInt8 = wordPositions.positions[0][index]
        updatedPositions[0] = nextPosition
        for wordIndex in 1..<wordPositions.numWords {
            let oneWordPositions: [UInt8] = wordPositions.positions[wordIndex]
            nextPosition += 1
            if oneWordPositions.contains(nextPosition) {
                updatedPositions[wordIndex] = nextPosition
            } else {
                return nil
            }
        }
        return updatedPositions
    }

    /**
     * This method searches for all verses that contain all of the words entered.
     * It also ensures that the words are in the sequence entered in the search.
     */
    func search3(bible: Bible, words: [String]) -> [WordRef] {
        var finalResult = [WordRef]()
        let results1: [WordRef] = self.search1(bible: bible, words: words)
        if results1.count == 0 {
            return finalResult
        }
        for index in 0..<results1.count {
            var wordRef = results1[index]
            let updatedPostions = self.matchToEachReference3(wordPositions: wordRef.wordPositions!)
            if updatedPostions.positions[0].count > 0 {
                wordRef.wordPositions = updatedPostions
                finalResult.append(wordRef)
            }
        }
        return finalResult
    }
    
    // This is identical to matchToEachReference2, except by calling matchToEachWord3
    private func matchToEachReference3(wordPositions: WordPositions) -> WordPositions {
        var updatedPositions = WordPositions(numWords: wordPositions.numWords)
        let firstWordPositions: [UInt8] = wordPositions.positions[0]
        for index in 0..<firstWordPositions.count {
            let matches: [UInt8]? = self.matchToEachWord3(wordPositions: wordPositions, index: index)
            if matches != nil {
                updatedPositions.addIfNewReference(positions: matches!)
            }
        }
        return updatedPositions
    }
    
    private func matchToEachWord3(wordPositions: WordPositions, index: Int) -> [UInt8]? {
        var updatedPositions: [UInt8] = Array(repeating: 0, count: wordPositions.numWords)
        var nextPosition: UInt8 = wordPositions.positions[0][index]
        updatedPositions[0] = nextPosition
        for wordIndex in 1..<wordPositions.numWords {
            let oneWordPositions: [UInt8] = wordPositions.positions[wordIndex]
            let greater: UInt8? = self.firstGreater3(array: oneWordPositions, num: nextPosition)
            if greater != nil {
                updatedPositions[wordIndex] = greater!
                nextPosition = greater!
            } else {
                return nil
            }
        }
        return updatedPositions
    }
        
    private func firstGreater3(array: [UInt8], num: UInt8) -> UInt8? {
        for val in array {
            if val > num {
                return val
            }
        }
        return nil
    }
}


