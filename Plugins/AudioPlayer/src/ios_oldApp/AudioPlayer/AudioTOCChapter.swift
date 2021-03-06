//
//  AudioTOCChapter.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/11/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import CoreMedia

class AudioTOCChapter {
    
    private var versePositions: [Double]
    
    init(json: String) {
        let start = json.index(json.startIndex, offsetBy: 1)
        let end = json.index(json.endIndex, offsetBy: -1)
        let trimmed = json[start..<end]
        let parts = trimmed.split(separator: ",")
        self.versePositions = [Double](repeating: 0.0, count: parts.count)
        for index in 1..<parts.count {
            if let dbl = Double(parts[index]) {
                self.versePositions[index] = dbl
            }
        }
        //print(self.versePositions)
    }
    
    deinit {
        print("***** Deinit AudioTOCChapter *****")
    }
    
    func hasPositions() -> Bool {
        return versePositions.count > 0
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
        return CMTime(seconds: seconds, preferredTimescale: CMTimeScale(1000))
    }
    
    func toString() -> String {
        var str = ""
        for (index, position) in self.versePositions.enumerated() {
            str += "verse_id=" + String(index) + ", position=" + String(position) + "\n"
        }
        return(str)
    }
}


