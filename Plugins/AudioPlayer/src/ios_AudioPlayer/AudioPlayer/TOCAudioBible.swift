//
//  MetaDataItem.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 8/8/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

//import Foundation

class TOCAudioBible {
    
    let mediaSource: String
    let damId: String
    let dbpLanguageCode: String
    let dbpVersionCode: String
    let collectionCode: String
    let mediaType: String
    var booksById: Dictionary<String, TOCAudioBook>
    var booksBySeq: Dictionary<Int, TOCAudioBook>
/*
    init(mediaSource: String, jsonObject: AnyObject) {
        self.booksById = Dictionary<String, TOCAudioBook>()
        self.booksBySeq = Dictionary<Int, TOCAudioBook>()
        self.mediaSource = mediaSource
        if jsonObject is Dictionary<String, AnyObject> {
            let item = jsonObject as! Dictionary<String, AnyObject>
            print("Inner Item \(item)")
            self.damId = item["dam_id"] as? String ?? ""
            self.dbpLanguageCode = item["language_code"] as? String ?? ""  // Not an attribute of damid
            self.mediaType = item["media"] as? String ?? ""             // Not an attribute of damid
            self.dbpVersionCode = item["version_code"] as? String ?? ""
            //self.versionName = item["version_name"] as? String ?? ""
            //self.versionEnglish = item["version_english"] as? String ?? ""
            self.collectionCode = item["collection_code"] as? String ?? ""
            
            let books = item["books"]
            if (books is Array<AnyObject>) {
                let array = books as! Array<AnyObject>
                print("is books array")
                for jsonBook in array {
                    let book = TOCAudioBook(jsonBook: jsonBook)
                    print("BOOK \(book.toString())")
                    self.booksById[book.bookId] = book
                    self.booksBySeq[book.sequence] = book
                }
            } else {
                print("Could not determine type of books array in MetaDataItem")
            }
        } else {
            print("Could not determine type of JSON Object in MetaDataItem")
            self.damId = ""
            self.dbpLanguageCode = ""
            self.mediaType = ""
            self.dbpVersionCode = ""
            //self.versionName = ""
            //self.versionEnglish = ""
            self.collectionCode = ""
        }
    }
  */
    init(database: Sqlite3, mediaSource: String, dbRow: [String?]) {
        self.booksById = Dictionary<String, TOCAudioBook>()
        self.booksBySeq = Dictionary<Int, TOCAudioBook>()
        self.mediaSource = mediaSource
        self.damId = dbRow[0]!
        self.collectionCode = dbRow[1]!
        self.mediaType = dbRow[2]!
        self.dbpLanguageCode = dbRow[3]!
        self.dbpVersionCode = dbRow[4]!

        let query = "SELECT bookId, bookOrder, numberOfChapters" +
            " FROM AudioBook" +
            " WHERE damId = '" + self.damId + "'"
        do {
            try database.stringSelect(query: query, complete: { resultSet in
                for row in resultSet {
                    let book = TOCAudioBook(dbRow: row)
                    print("\(book.toString())")
                    self.booksById[book.bookId] = book
                    self.booksBySeq[book.sequence] = book
                }
            })
        } catch let err {
            print("ERROR \(Sqlite3.errorDescription(error: err))")
        }
    }
    
    deinit {
       print("***** Deinit TOCAudioBible *****") 
    }
    
    func nextChapter(reference: Reference) -> Reference? {
        let ref = reference
        if let book = self.booksById[ref.book] {
            if (ref.chapterNum < book.numberOfChapters) {
                let next = ref.chapterNum + 1
                let nextStr = String(next)
                switch(nextStr.count) {
                    case 1: return Reference(damId: reference.damId, sequence: ref.sequence, book: ref.book,
                                             bookName: ref.bookName, chapter: "00" + nextStr,
                                             fileType: reference.fileType)
                    case 2: return Reference(damId: reference.damId, sequence: ref.sequence, book: ref.book,
                                             bookName: ref.bookName, chapter: "0" + nextStr,
                                             fileType: reference.fileType)
                    default: return Reference(damId: reference.damId, sequence: ref.sequence, book: ref.book,
                                              bookName: ref.bookName, chapter: nextStr,
                                              fileType: reference.fileType)
                }
            } else {
                if let nextBook = self.booksBySeq[reference.sequenceNum + 1] {
                    return Reference(damId: reference.damId, sequence: nextBook.bookOrder,
                                     book: nextBook.bookId,
                                     bookName: nextBook.bookName, chapter: "001", fileType: reference.fileType)
                }
            }
        }
        return nil
    }
    
    func toString() -> String {
        let str = "damId=" + self.damId +
                "\n languageCode=" + self.dbpLanguageCode +
                "\n versionCode=" + self.dbpVersionCode +
                "\n mediaType=" + self.mediaType +
                "\n collectionCode=" + self.collectionCode
        return str
    }
}
