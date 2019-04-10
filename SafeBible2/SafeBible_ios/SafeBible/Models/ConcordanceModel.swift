//
//  SearchModel.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/8/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

struct TempWordRef {//}: Equatable {
    let nodeId: String
    var position: Int  // Should be unsigned byte, or unsigned short
    
    init(reference: String) {
        let parts = reference.components(separatedBy: ";")
        self.nodeId = parts[0]
        self.position = Int(parts[1])!
    }
    
    var reference: String {
        get {
            return self.nodeId + ";" + String(self.position)
        }
    }
    
    mutating func next() {
        self.position += 1
    }
    
    //static func == (lhs: WordRef, rhs: WordRef) -> Bool {
    //    return lhs.nodeId == rhs.nodeId && lhs.position == rhs.position
    //}
}

struct ConcordanceModel {
    
    let wordsLookAhead = 0
    
    /**
    * This method searches for all verses that contain all of the words entered.
    * It does not consider the position of the words or the number of times they occur.
    */
    func search1(bible: Bible, words: [String]) -> [String] {
        if words.count == 0 {
            return [String]()
        }
        let refLists2: [[String]] = BibleDB.shared.selectRefList2(bible: bible, words: words)
        if refLists2.count != words.count {
            return [String]()
        }
        var refLists = [[String]]()
        for list in refLists2 {
            refLists.append(list.map{ $0.components(separatedBy: ";")[0] })
        }
        let setList: [Set<String>] = refLists.map { Set($0) }
        
        var result = [String]()
        let shortList = self.findShortest(refLists: refLists)
        for reference in shortList {
            if presentInAllSets(setList: setList, reference: reference) {
                result.append(reference)
            }
        }
        return result
    }
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
    private func presentInAllSets(setList: [Set<String>], reference: String) -> Bool {
        for set in setList {
            if !set.contains(reference) {
                return false
            }
        }
        return true
    }

    /**
    * This method searches for all of the words entered, but only returns references
    * where they are entered in the consequtive order of the search parameters.
    */
    func search2(bible: Bible, words: [String]) -> [String] {
        if words.count == 0 {
            return [String]()
        }
        let refLists2 = BibleDB.shared.selectRefList2(bible: bible, words: words)
        if refLists2.count != words.count {
            return [String]()
        }
        let setList: [Set<String>] = refLists2.map { Set($0) }
        print(setList)
        
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
}


