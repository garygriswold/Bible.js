//
//  SearchModel.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/8/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

//import Foundation

struct ConcordanceModel {
    
    let wordsLookAhead = 0
    
    func search1(bible: Bible, words: [String]) -> [String] {
        let refLists2: [[String]] = BibleDB.shared.selectRefList2(bible: bible, words: words)
        var refLists = [[String]]()
        for list in refLists2 {
            refLists.append(list.map{ $0.components(separatedBy: ";")[0] })
        }
        if refLists.count == 0 {
            return [String]()
        }
        if refLists.count == 1 {
            return refLists[0]
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
//        function intersection(refLists) {
//            if (refLists.length === 0) {
//                return([]);
//            }
//            if (refLists.length === 1) {
//                return(refLists[0]);
//            }
//            var mapList = [];
//            for (var i=1; i<refLists.length; i++) {
//                var map = arrayToMap(refLists[i]);
//                mapList.push(map);
//            }
//            var result = [];
//            var firstList = refLists[0];
//            for (var j=0; j<firstList.length; j++) {
//                var reference = firstList[j];
//                if (presentInAllMaps(mapList, reference)) {
//                    result.push(reference);
//                }
//            }
//            return(result);
//        }
//        function arrayToMap(array) {
//            var map = {};
//            for (var i=0; i<array.length; i++) {
//                map[array[i]] = true;
//            }
//            return(map);
//        }
//        function presentInAllMaps(mapList, reference) {
//            for (var i=0; i<mapList.length; i++) {
//                if (mapList[i][reference] === undefined) {
//                    return(false);
//                }
//            }
//            return(true);
//        }
//    };
/*
    func search2(bible: Bible, words: [String]) -> [[String]] {
        let refList2 = BibleDB.shared.selectRefList2(bible: bible, words: words)
        
    }
 */
//    Concordance.prototype.search2 = function(words, callback) {
//        var that = this;
//        this.adapter.select2(words, function(refLists) {
//            if (refLists instanceof IOError) {
//                callback(refLists);
//            } else if (refLists.length !== words.length) {
//                callback([]);
//            } else {
//                var resultList = intersection(refLists);
//                callback(resultList);
//            }
//        });
/*
    private func intersection(refLists: [[String]]) -> [String] {
        var resultList = [String]()
        if refLists.count == 0 {
            return resultList
        }
        if refLists.count == 1 {
            return refLists[0]
        }
        var mapList = [[String:Bool]]()
        for item in refLists {
            let map = arrayToMap(array: item)
            mapList.append(map)
        }
        let firstList = refLists[0]
        for reference in firstList {
            var resultItem = matchEachWord(mapList: mapList, reference: reference)
            resultList.append(resultItem)
        }
        return resultList
    }
 */
//        function intersection(refLists) {
//            if (refLists.length === 0) {
//                return([]);
//            }
//            var resultList = [];
//            if (refLists.length === 1) {
//                for (var ii=0; ii<refLists[0].length; ii++) {
//                    resultList.push([refLists[0][ii]]);
//                }
//                return(resultList);
//            }
//            var mapList = [];
//            for (var i=1; i<refLists.length; i++) {
//                var map = arrayToMap(refLists[i]);
//                mapList.push(map);
//            }
//            var firstList = refLists[0];
//            for (var j=0; j<firstList.length; j++) {
//                var reference = firstList[j];
//                var resultItem = matchEachWord(mapList, reference);
//                if (resultItem) {
//                    resultList.push(resultItem);
//                }
//            }
//            return(resultList);
//        }
    private func arrayToMap(array: [String]) -> [String: Bool] {
        var map = [String: Bool]()
        for item in array {
            map[item] = true
        }
        return map
    }
//        function arrayToMap(array) {
//            var map = {};
//            for (var i=0; i<array.length; i++) {
//                map[array[i]] = true;
//            }
//            return(map);
//        }
    private func matchEachWord(mapList: [[String: Bool]], reference: String) -> [String] {
        var resultItem = [reference]
        for i in 0..<mapList.count {
            let reference = self.matchWordWithLookahead(mapRef: mapList[i], reference: reference)
            if reference == nil {
                //return nil
                return []
            }
            resultItem.append(reference!)
        }
        return resultItem
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
//        }
    private func matchWordWithLookahead(mapRef: [String: Any], reference: String) -> String? {
        for look in 1..<(self.wordsLookAhead + 1) {
            let next = self.nextPosition(reference: reference, position: look)
            if mapRef[next] != nil {
                return next
            }
        }
        return nil
    }
//        function matchWordWithLookahead(mapRef, reference) {
//            for (var look=1; look<=that.wordsLookAhead + 1; look++) {
//                var next = nextPosition(reference, look);
//                if (mapRef[next]) {
//                    return(next);
//                }
//            }
//            return(null);
//        }
    private func nextPosition(reference: String, position: Int) -> String {
        let parts = reference.components(separatedBy: ";")
        let next = Int(parts[1])! + position
        return parts[0] + ";" + String(next)
    }
//        function nextPosition(reference, position) {
//            var parts = reference.split(';');
//            var next = parseInt(parts[1]) + position;
//            return(parts[0] + ';' + next.toString());
//        }
//    };
}
