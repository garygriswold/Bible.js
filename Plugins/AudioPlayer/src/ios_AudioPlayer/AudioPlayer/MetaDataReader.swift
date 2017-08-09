//
//  MetaDataReader.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/7/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation
import AWS

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
        AwsS3.shared.downloadData(
            s3Bucket: "audio-us-west-2-shortsands",
            s3Key: self.languageCode + "-" + self.mediaType + ".json",
            complete: { error, data in
                print("DOWNLOADED err \(String(describing: error))  data \(String(describing: data))")
                if let err = error {
                    print("Download Meta Data Error \(err)")
                } else if let json = data {
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
                    print("Download neither error or Meta Data")
                }
                readComplete(self.metaData)
            }
        )
    }
}



