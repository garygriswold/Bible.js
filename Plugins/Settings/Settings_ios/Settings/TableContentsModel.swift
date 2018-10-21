//
//  TableContentsModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/20/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import Foundation
import AWS

struct Book : Equatable {
    let bookId: String
    let ordinal: Int
    let name: String
    let lastChapter: Int
    
    static func == (lhs: Book, rhs: Book) -> Bool {
        return lhs.bookId == rhs.bookId
    }
}

class TableContentsModel { // class is used to permit self.contents inside closure
    
    let bible: Bible
    var contents: [Book]
    
    init(bible: Bible) {
        self.bible = bible
        self.contents = [Book]()
    }
    
    func load() {
        let start: Double = CFAbsoluteTimeGetCurrent()
        let bibleDB = BibleDB(bible: bible)
        self.contents = bibleDB.getTableContents()
        if self.contents.count < 1 {
            AwsS3Manager.findDbp().downloadData(s3Bucket: "dbp-prod",
                                       s3Key: "text/\(self.bible.bibleId)/\(self.bible.bibleId)/info.json",
                                       complete: { error, data in
                                        if let data1 = data {
                                            print(data1)
                                            self.contents = self.parseJSON(data: data1)
                                            _ = bibleDB.storeTableContents(books: self.contents)
                                            print("*** TableContentsModel.AWS load duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
                                        }
            })
        }
        print("*** TableContentsModel.DB load duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
    }
    
    private func parseJSON(data: Data) -> [Book] {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                let bookIds = json["divisions"] as? [String]
                let bookNames = json["divisionNames"] as? [String]
                let chapters = json["sections"] as? [String]
                let lastChapters = self.findLastChapters(chapters: chapters)
                return self.buildTableContents(bookIds: bookIds!, names: bookNames!,
                                              chapters: lastChapters)
            } else {
                return [Book]()
            }
        } catch let err {
            print(err)
            return [Book]()
        }
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
    
    private func buildTableContents(bookIds: [String], names: [String], chapters: [String: Int]) -> [Book] {
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
