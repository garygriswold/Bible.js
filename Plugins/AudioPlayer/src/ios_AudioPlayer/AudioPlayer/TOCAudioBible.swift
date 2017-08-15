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
    var booksById: Dictionary<String, TOCAudioBook>
    var bookSeq: Array<String>

    init(jsonObject: AnyObject) {
        self.booksById = Dictionary<String, TOCAudioBook>()
        self.bookSeq = Array<String>()
        if jsonObject is Dictionary<String, AnyObject> {
            let item = jsonObject as! Dictionary<String, AnyObject>
            print("Inner Item \(item)")
            self.damId = item["dam_id"] as? String ?? ""
            self.languageCode = item["language_code"] as? String ?? ""  // Not an attribute of damid
            self.mediaType = item["media"] as? String ?? ""             // Not an attribute of damid
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
                    self.booksById[book.bookId] = book
                    self.bookSeq.append(book.bookId)
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
    
    func nextChapter(reference: Reference) -> Reference? {
        let ref = reference
        if let book = self.booksById[ref.book] {
            if (ref.chapterNum < book.numberOfChapters) {
                let next = ref.chapterNum + 1
                let nextStr = String(next)
                switch(nextStr.characters.count) {
                    case 1: return Reference(sequence: ref.sequence, book: ref.book, chapter: "00" + nextStr)
                    case 2: return Reference(sequence: ref.sequence, book: ref.book, chapter: "0" + nextStr)
                    default: return Reference(sequence: ref.sequence, book: ref.book, chapter: nextStr)
                }
            } else {
                let penultimate = self.bookSeq.count // stop 1 before last
                for i in 0..<penultimate {
                    if (self.bookSeq[i] == book.bookId) {
                        if let nextBook = self.booksById[self.bookSeq[i+1]] {
                            return Reference(sequence: nextBook.sequence, book: nextBook.bookId, chapter: "001")
                        }
                    }
                }
            }
        }
        return nil
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