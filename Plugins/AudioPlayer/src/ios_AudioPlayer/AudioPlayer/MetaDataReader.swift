//
//  MetaDataReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation

class MetaDataReader {
    
    let languageCode: String
    let mediaType: String
    var metaData: Dictionary<String, MetaDataItem>
    
    init(languageCode: String, mediaType: String) {
        self.languageCode = languageCode
        self.mediaType = mediaType
        self.metaData = Dictionary<String, MetaDataItem>()
    }
    
    func read(readComplete: @escaping (_ metaData: Dictionary<String, MetaDataItem>) -> Void) {
        let cache = AWSS3Cache()
        cache.read(s3Bucket: "audio-us-west-2-shortsands",
                   s3Key: self.languageCode + "_" + self.mediaType + ".json",
                   getComplete: { data in
            if let json = data {
                do {
                    let result = try JSONSerialization.jsonObject(with: json, options: [])
                    if (result is Array<AnyObject>) {
                        let array: Array<AnyObject> = result as! Array<AnyObject>
                        for item in array {
                            let metaItem = MetaDataItem(jsonObject: item)
                            print("\(metaItem.toString())")
                            self.metaData[metaItem.damId] = metaItem
                        }
                    } else {
                        print("Could not determine type of outer object in Meta Data")
                    }
                } catch let jsonError {
                    print("Error parsing Meta Data json \(jsonError)")
                }
            } else {
                print("Download Meta Data Error")
            }
            readComplete(self.metaData)
        })
    }
}



