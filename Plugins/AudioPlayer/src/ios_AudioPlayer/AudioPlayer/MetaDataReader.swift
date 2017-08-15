//
//  MetaDataReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation

class MetaDataReader {
    
    var metaData: Dictionary<String, TOCAudioBible>
    var metaDataVerse: TOCAudioChapter?
    
    init() {
        self.metaData = Dictionary<String, TOCAudioBible>()
    }
    
    func read(languageCode: String, mediaType: String,
              readComplete: @escaping (_ metaData: Dictionary<String, TOCAudioBible>) -> Void) {
        let cache = AWSS3Cache()
        cache.read(s3Bucket: "audio-us-west-2-shortsands",
                   s3Key: languageCode + "_" + mediaType + ".json",
                   getComplete: { data in
            let result = self.parseJson(data: data)
            if (result is Array<AnyObject>) {
                let array: Array<AnyObject> = result as! Array<AnyObject>
                for item in array {
                    let metaItem = TOCAudioBible(jsonObject: item)
                    print("\(metaItem.toString())")
                    self.metaData[metaItem.damId] = metaItem
                }
            } else {
                print("Could not determine type of outer object in Meta Data")
            }
            readComplete(self.metaData)
        })
    }
    
    func readVerseAudio(damid: String, sequence: String, bookId: String, chapter: String,
                        readComplete: @escaping (_ audioVerse: TOCAudioChapter?) -> Void) {
        let cache = AWSS3Cache()
        let s3Key = damid + "_" + sequence + "_" + bookId + "_" + chapter + "_verse.json"
        cache.read(s3Bucket: "audio-us-west-2-shortsands",
                   s3Key: s3Key,
                   getComplete: { data in
            let result = self.parseJson(data: data)
            self.metaDataVerse = TOCAudioChapter(jsonObject: result)
            readComplete(self.metaDataVerse)
        })
    }
    
    private func parseJson(data: Data?) -> Any? {
        if let json = data {
            do {
                let result = try JSONSerialization.jsonObject(with: json, options: [])
                return result
            } catch let jsonError {
                print("Error parsing Meta Data json \(jsonError)")
                return nil
            }
        } else {
            print("Download Meta Data Error")
            return nil
        }
    }
}



