//
//  TableContentsModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/20/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import Foundation

struct Book : Equatable {
    let bookId: String
    let ordinal: Int
    let name: String
    let lastChapter: Int
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.bookId == rhs.bookId
    }
}

struct TableContentsModel {
    
    let bible: Bible
    var contents: [Book]
    
    init?(bible: Bible) {
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.bible = bible
        let bibleDB = BibleDB(bible: bible)
        self.contents = bibleDB.getTableContents()
        if self.contents.count < 1 {
            let bundle: Bundle = Bundle.main
            let path = bundle.path(forResource: "www/test:ENGKJV:ENGKJV:info", ofType: "json")
            let url = URL(fileURLWithPath: path!)
            do {
                let data = try Data(contentsOf: url)
                self.contents = parseJSON(data: data)
                let start2: Double = CFAbsoluteTimeGetCurrent()
                _ = bibleDB.storeTableContents(books: self.contents)
                print("*** Store duration \((CFAbsoluteTimeGetCurrent() - start2) * 1000) ms")
                //let start3: Double = CFAbsoluteTimeGetCurrent()
                //self.contents = bibleDB.getTableContents()
                //print("*** Get duration \((CFAbsoluteTimeGetCurrent() - start3) * 1000) ms")
                //print(self.contents)
                
            // perform a get from AWS.
            // populate the database and model, or populate the database and then model
            // how do I handle async aspect of this?
            } catch let err {
                print(err)
            }
        }
        print("*** TableContentsModel.init duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    private func parseJSON(data: Data) -> [Book] {
        let books: [Book]
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                let bookIds = json["divisions"] as? [String]
                let bookNames = json["divisionNames"] as? [String]
                let chapters = json["sections"] as? [String]
                //print(chapters)
                let lastChapters = self.findLastChapters(chapters: chapters)
                books = self.assmTableContents(bookIds: bookIds!, names: bookNames!, chapters: lastChapters)
            } else {
                books = [Book]()
            }
        } catch let err {
            print(err)
            books = [Book]()
        }
        return books
    }
    
    private func findLastChapters(chapters: [String]?) -> [String: Int] {
        var lastChapters = [String: Int]()
        if chapters != nil {
            for chapter in chapters! {
                let book = String(chapter.prefix(3))
                let num = Int(chapter.suffix(chapter.count - 3))
                lastChapters[book] = num
            }
        }
        return lastChapters
    }
    
    private func assmTableContents(bookIds: [String], names: [String], chapters: [String: Int]) -> [Book] {
        var books = [Book]()
        for index in 0..<bookIds.count {
            let bookId = bookIds[index]
            let book = Book(bookId: bookId, ordinal: index, name: names[index],
                            lastChapter: chapters[bookId] ?? 1)
            books.append(book)
        }
        return books
    }
}
