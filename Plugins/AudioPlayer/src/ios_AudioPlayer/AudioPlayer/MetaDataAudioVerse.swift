//
//  MetaDataAudioVerse.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/11/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation

class MetaDataAudioVerse {
    
    var versePositions: [Int]
    
    init(jsonObject: Any?) {
        self.versePositions = [Int]()
        
        if (jsonObject is Array<AnyObject>) {
            let array: Array<AnyObject> = jsonObject as! Array<AnyObject>
            if (array.count > 0) {
                let lastVerse: Int = array.last!["verse_id"] as? Int ?? 0
                print("LAST VERSE \(lastVerse)")
                self.versePositions = Array(repeating: 0, count: lastVerse + 1)
                for item in array {
                    let verseId = item["verse_id"] as? Int ?? 0
                    let position = item["position"] as? Int ?? 0
                    self.versePositions[verseId] = position
                }
            } else {
                print("The verse array was length zero")
            }
        } else {
            print("Could not determine type of outer object in Meta Data")
        }
    }
    
    func toString() -> String {
        var str = ""
        for (index, position) in self.versePositions.enumerated() {
            str += "verse_id=" + String(index) + ", position=" + String(position) + "\n"
        }
        return(str)
    }
}
