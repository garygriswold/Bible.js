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
    
    var versePositions: [Float]
    
    init(jsonObject: Any?) {
        self.versePositions = [Float]()
        
        if (jsonObject is Array<AnyObject>) {
            let array: Array<AnyObject> = jsonObject as! Array<AnyObject>
            if (array.count > 0) {
                let lastVerse: Int = array.last!["verse_id"] as? Int ?? 0
                print("LAST VERSE \(lastVerse)")
                self.versePositions = Array(repeating: 0, count: lastVerse + 1)
                for item in array {
                    let verseId = item["verse_id"] as? Int ?? 0
                    let position = item["position"] as? Float ?? 0.0
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
    
    func findVerseByPosition(time: CMTime) -> CMTime {
        let seconds = Float(CMTimeGetSeconds(time))
        let priorVerseSec: Float = findVerseByPosition(seconds: seconds)
        return CMTime(seconds: Double(priorVerseSec), preferredTimescale: CMTimeScale(1))
    }
    
    func findVerseByPosition(seconds: Float) -> Float {
        var index = 0
        for versePos in self.versePositions {
            if (seconds == versePos) {
                return seconds
            } else if (seconds < versePos) {
                return (index > 0) ? self.versePositions[index - 1] : 0.0
            }
            index += 1
        }
        return (self.versePositions.count > 0) ? self.versePositions.last! : 0.0
    }
    
    func toString() -> String {
        var str = ""
        for (index, position) in self.versePositions.enumerated() {
            str += "verse_id=" + String(index) + ", position=" + String(position) + "\n"
        }
        return(str)
    }
}


