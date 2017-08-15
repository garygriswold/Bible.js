//
//  MetaDataItem.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation

class TOCAudioBible {
    
    let damId: String
    let languageCode: String
    let mediaType: String
    let versionCode: String
    let versionName: String
    let versionEnglish: String
    let collectionCode: String
    var books: Dictionary<String, TOCAudioBook>

    init(jsonObject: AnyObject) {
        self.books = Dictionary<String, TOCAudioBook>()
        if jsonObject is Dictionary<String, AnyObject> {
            let item = jsonObject as! Dictionary<String, AnyObject>
            print("Inner Item \(item)")
            self.damId = item["dam_id"] as? String ?? ""
            self.languageCode = item["language_code"] as? String ?? ""
            self.mediaType = item["media"] as? String ?? ""
            self.versionCode = item["version_code"] as? String ?? ""
            self.versionName = item["version_name"] as? String ?? ""
            self.versionEnglish = item["version_english"] as? String ?? ""
            self.collectionCode = item["collection_code"] as? String ?? ""
            
            let books = item["books"]
            if (books is Array<AnyObject>) {
                let array = books as! Array<AnyObject>
                print("is books array")
                for jsonBook in array {
                    let book = TOCAudioBook(jsonBook: jsonBook)
                    print("BOOK \(book.toString())")
                    self.books[book.bookId] = book
                }
            } else {
                print("Could not determine type of books array in MetaDataItem")
            }
        } else {
            print("Could not determine type of JSON Object in MetaDataItem")
            self.damId = ""
            self.languageCode = ""
            self.mediaType = ""
            self.versionCode = ""
            self.versionName = ""
            self.versionEnglish = ""
            self.collectionCode = ""
        }

    }
    
    func toString() -> String {
        let str = "damId=" + self.damId +
                "\n languageCode=" + self.languageCode +
                "\n mediaType=" + self.mediaType +
                "\n versionCode=" + self.versionCode +
                "\n versionName=" + self.versionName +
                "\n versionEnglish=" + self.versionEnglish +
                "\n collectionCode=" + self.collectionCode
        return str
    }
}
