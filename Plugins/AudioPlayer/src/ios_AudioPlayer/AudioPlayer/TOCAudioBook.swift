//
//  MetaDataItemBook.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

//import Foundation

class TOCAudioBook {
    
    let bookId: String
    let bookOrder: String
    let sequence: Int
    let bookName: String // I don't know why this is here.  Can I remove it?
    let numberOfChapters: Int
    /*
    init(jsonBook: AnyObject) {
        if jsonBook is Dictionary<String, String> {
            let item = jsonBook as! Dictionary<String, String>
            self.bookId = item["book_id"] ?? ""
            self.bookOrder = item["sequence"] ?? "000"
            self.sequence = Int(self.bookOrder)
            let chapters = item["number_of_chapters"] ?? "0"
            self.numberOfChapters = Int(chapters)!
        } else {
           print("Could not determine type of book in MetaDataItemBook")
            self.bookId = ""
            self.bookOrder = "000"
            self.sequence = 0
            self.bookName = ""
            self.numberOfChapters = 0
        }
    }
    */
    init(dbRow: [String?]) {
        self.bookId = dbRow[0]!
        self.bookOrder = dbRow[1]!
        self.sequence = Int(self.bookOrder) ?? 0
        self.bookName = ""
        let chapters = dbRow[2]!
        self.numberOfChapters = Int(chapters) ?? 0
    }
    
    deinit {
        print("***** Deinit TOCAudioBook *****")
    }
    
    func toString() -> String {
        let str = "bookId=" + self.bookId +
            ", bookOrder=" + self.bookOrder +
            ", numberOfChapter=" + String(self.numberOfChapters)
        return str
    }
}
