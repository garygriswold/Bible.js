//
//  SearchModel.swift
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
    var position: UInt8
    
    init(reference: String) {
        let parts = reference.components(separatedBy: WordRef.delims)
        self.bookId = parts[0]
        self.chapter = UInt8(parts[1])!
        self.verse = UInt8(parts[2])!
        self.position = UInt8(parts[3])!
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
    
    init() {
        self.positions = [[UInt8]]()
    }
    
    mutating func addWord(positions: [UInt8]) {
        self.positions.append(positions)
    }
}


struct ConcordanceModel {
    
    struct TempWordRef : Equatable, Hashable {
        let nodeId: String
        var position: Int  // Should be unsigned byte, or unsigned short
        
        init(reference: String) {
            let parts = reference.components(separatedBy: ";")
            self.nodeId = parts[0]
            self.position = Int(parts[1])!
        }
        
        //var hashValue: Int {
        //    return self.nodeId.hashValue
        //}
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.nodeId)
        }
        
        var reference: String {
            get {
                return self.nodeId + ";" + String(self.position)
            }
        }
        
        mutating func next() {
            self.position += 1
        }
        
        static func == (lhs: TempWordRef, rhs: TempWordRef) -> Bool {
            //return lhs.nodeId == rhs.nodeId && lhs.position == rhs.position
            return lhs.nodeId == rhs.nodeId
        }
    }
    
    //let wordsLookAhead = 0
    
    /**
    * This method searches for all verses that contain all of the words entered.
    * It does not consider the position of the words or the number of times they occur.
    */
    func search1(bible: Bible, words: [String]) -> [WordRef: WordPositions] {
        var result = [WordRef: WordPositions]()
        let measure = Measurement()
        if words.count == 0 {
            return result
        }
        let mapList: [[WordRef: [UInt8]]] = BibleDB.shared.selectRefList3(bible: bible, words: words)
        if mapList.count != words.count {
            return result
        }
        let firstList = mapList[0]
        measure.duration(location: "finish database")
        for (reference, _) in firstList {
            let wordPos = presentInAllSets(mapList: mapList, reference: reference)
            if wordPos != nil {
                result[reference] = wordPos
            }
        }
        measure.final(location: "search1")
        return result
    }
    
    private func presentInAllSets(mapList: [[WordRef: [UInt8]]], reference: WordRef) -> WordPositions? {
        var result = WordPositions()
        for map in mapList {
            let wordPositions = map[reference]
            if wordPositions == nil {
                return nil
            } else {
                result.addWord(positions: wordPositions!)
            }
        }
        return result
    }

    /**
    * This method searches for all of the words entered, but only returns references
    * where they are entered in the consequtive order of the search parameters.
    */
    func search2(bible: Bible, words: [String]) -> [WordRef: WordPositions] {
        var finalResult = [WordRef: WordPositions]()
        let results1 = self.search1(bible: bible, words: words)
        if results1.count == 0 {
            return finalResult
        }
        for (wordRef, positions) in results1 {
            let first = positions.positions[0][0]
            let updatedPostions = self.matchToNext(wordPositions: positions, firstPosition: first)
            if updatedPostions != nil {
                finalResult[wordRef] = updatedPostions
            }
        }
        return finalResult
    }
    private func matchToNext(wordPositions: WordPositions, firstPosition: UInt8) -> WordPositions? {
        var updatedPositions = WordPositions()
        var nextPosition = firstPosition
        for oneWordPositions in wordPositions.positions {
        //for index in 0..<wordPositions.positions.count {
        //    let oneWordPositions = wordPositions.positions[index]
            if !oneWordPositions.contains(nextPosition) {
                return nil
            }
            
            updatedPositions.addWord(positions: [nextPosition])
            nextPosition += 1
        }
        return wordPositions
    }
    
    // var positions = Array(count: numWords, repeatedValue: [UInt8])

    func search2old(bible: Bible, words: [String]) -> [String] {
        if words.count == 0 {
            return [String]()
        }
        let refLists2 = BibleDB.shared.selectRefList2(bible: bible, words: words)
        if refLists2.count != words.count {
            return [String]()
        }
        let setList: [Set<String>] = refLists2.map { Set($0) }
        //print(setList)
        
        var result = [String]()
        let firstList = refLists2[0]
        for reference in firstList {
            if self.matchEachWord(setList: setList, reference: reference) {
                result.append(reference)
            }
        }
        return result
    }
    
    private func matchEachWord(setList: [Set<String>], reference: String) -> Bool {
        var wordRef = TempWordRef(reference: reference)
        for set in setList {
            if !set.contains(wordRef.reference) {
                return false
            }
            wordRef.next()
        }
        return true
    }
//        function matchEachWord(mapList, reference) {
//            var resultItem = [ reference ];
//            for (var i=0; i<mapList.length; i++) {
//                reference = matchWordWithLookahead(mapList[i], reference);
//                if (reference == null) {
//                    return(null);
//                }
//                resultItem.push(reference);
//            }
//            return(resultItem);
//
//}
/*
    private func matchWordWithLookahead(refSet: Set<String>, reference: TempWordRef) -> Bool {
        for look in 0..<(self.wordsLookAhead + 2) {
            let next = reference.reference(add: look)
            if refSet.contains(next) {
                return true
            }
        }
        return false
    }
 */
//        function matchWordWithLookahead(mapRef, reference) {
//            for (var look=1; look<=that.wordsLookAhead + 1; look++) {
//                var next = nextPosition(reference, look);
//                if (mapRef[next]) {
//                    return(next);
//                }
//            }
//            return(null);
//        }
//        function nextPosition(reference, position) {
//            var parts = reference.split(';');
//            var next = parseInt(parts[1]) + position;
//            return(parts[0] + ';' + next.toString());
//        }
//    };
    /**
     * This method searches for all verses that contain all of the words entered.
     * It also ensures that the words are in the sequence entered in the search.
     */
    func search3(bible: Bible, words: [String]) -> [TempWordRef] {
        let measure = Measurement()
        if words.count == 0 {
            return [TempWordRef]()
        }
        let refLists2: [[String]] = BibleDB.shared.selectRefList2(bible: bible, words: words)
        measure.duration(location: "database select")
        if refLists2.count != words.count {
            return [TempWordRef]()
        }
        var refLists = [[TempWordRef]]()
        for list in refLists2 {
            refLists.append(list.map { TempWordRef(reference: $0) })
        }
        measure.duration(location: "remove position")
        let setList: [Set<TempWordRef>] = refLists.map { Set($0) }
        measure.duration(location: "make sets")
        
        var result = [TempWordRef]()
        let shortList = self.findShortest(refLists: refLists)
        measure.duration(location: "find shortest")
        for reference in shortList {
            if presentInAllSets(setList: setList, reference: reference) {
                result.append(reference)
            }
        }
        measure.final(location: "search3")
        return result
    }
    private func findShortest(refLists: [[TempWordRef]]) -> [TempWordRef] {
        var count = 100000
        var best = 0
        for index in 0..<refLists.count {
            if refLists[index].count < count {
                count = refLists[index].count
                best = index
            }
        }
        return refLists[best]
    }
    private func presentInAllSets(setList: [Set<TempWordRef>], reference: TempWordRef) -> Bool {
        for set in setList {
            if !set.contains(reference) {
                return false
            }
        }
        return true
    }
    
    //
    // Shared?
    //
    private func findShortest(refLists: [[String]]) -> [String] {
        var count = 100000
        var best = 0
        for index in 0..<refLists.count {
            if refLists[index].count < count {
                count = refLists[index].count
                best = index
            }
        }
        return refLists[best]
    }
}


