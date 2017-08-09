//
//  MetaDataItemBook.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import Foundation

class MetaDataItemBook {
    
    let bookId: String
    let bookName: String
    let numberOfChapters: Int
    
    init(jsonBook: AnyObject) {
        if jsonBook is Dictionary<String, String> {
            let item = jsonBook as! Dictionary<String, String>
            self.bookId = item["book_id"] ?? ""
            self.bookName = item["book_name"] ?? ""
            let chapters = item["number_of_chapters"] ?? "0"
            self.numberOfChapters = Int(chapters)!
        } else {
           print("Could not determine type of book in MetaDataItemBook")
            self.bookId = ""
            self.bookName = ""
            self.numberOfChapters = 0
        }
    }
    
    func toString() -> String {
        let str = "bookId=" + self.bookId +
            ", bookName=" + self.bookName +
            ", numberOfChapter=" + String(self.numberOfChapters)
        return str
    }
}
