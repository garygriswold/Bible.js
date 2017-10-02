//
//  MetaDataAudioVerse.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/11/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import CoreMedia

class TOCAudioChapter {
    
    var versePositions: [Double]
    
    init(jsonObject: Any?) {
        self.versePositions = [Double]()
        
        if (jsonObject is Array<AnyObject>) {
            let array: Array<AnyObject> = jsonObject as! Array<AnyObject>
            if (array.count > 0) {
                let lastVerse: Int = array.last!["verse_id"] as? Int ?? 0
                print("LAST VERSE \(lastVerse)")
                self.versePositions = Array(repeating: 0, count: lastVerse + 1)
                for item in array {
                    let verseId = item["verse_id"] as? Int ?? 0
                    let position = item["position"] as? Double ?? 0.0
                    self.versePositions[verseId] = position
                }
            } else {
                print("The verse array was length zero")
            }
        } else {
            print("Could not determine type of outer object in Meta Data")
        }
    }
    
    deinit {
        print("***** Deinit TOCAudioChapter *****")
    }
    
    func findVerseByPosition(priorVerse: Int, time: CMTime) -> Int {
         let seconds = Double(CMTimeGetSeconds(time))
        return findVerseByPosition(priorVerse: priorVerse, seconds: seconds)
    }
    
    func findVerseByPosition(priorVerse: Int, seconds: Double) -> Int {
        var index = (priorVerse > 0 && priorVerse < self.versePositions.count) ? priorVerse : 1
        let priorPosition = self.versePositions[index]
        if (seconds > priorPosition) {
            while(index < (self.versePositions.count - 1)) {
                index += 1
                let versePos = self.versePositions[index]
                if (seconds < versePos) {
                    return index - 1
                }
            }
            return self.versePositions.count - 1
            
        } else if (seconds < priorPosition) {
            while(index > 2) {
                index -= 1
                let versePos = self.versePositions[index]
                if (seconds >= versePos) {
                    return index
                }
            }
            return 1
            
        } else { // seconds == priorPosition
            return index
        }
    }
    
    func findPositionOfVerse(verse: Int) -> CMTime {
        let seconds = (verse > 0 && verse < self.versePositions.count) ? self.versePositions[verse] : 0.0
        return CMTime(seconds: seconds, preferredTimescale: CMTimeScale(1))
    }
    
    func toString() -> String {
        var str = ""
        for (index, position) in self.versePositions.enumerated() {
            str += "verse_id=" + String(index) + ", position=" + String(position) + "\n"
        }
        return(str)
    }
}


