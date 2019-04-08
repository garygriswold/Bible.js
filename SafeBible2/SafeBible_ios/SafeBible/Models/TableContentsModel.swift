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
    
    private let bible: Bible
    private var books: [Book]
    private var filtered: [Book] // Used for TOCBookView
    private var bookMap: [String:Book]
    private var index: [String]
    
    init(bible: Bible) {
        print("****** init TableContentsModel \(bible.bibleId) ******")
        self.bible = bible
        self.books = [Book]()
        self.filtered = self.books
        self.bookMap = [String:Book]()
        self.index = [String]()
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.books = BibleDB.shared.getTableContents(bible: bible)
        if self.books.count < 1 {
            let s3 = (bible.textBucket.contains("shortsands")) ? AwsS3Manager.findSS() : AwsS3Manager.findDbp()
            s3.downloadData(s3Bucket: self.bible.textBucket, s3Key: "\(self.bible.textId)/info.json",
                complete: { error, data in
                    if let data1 = data {
                        print(data1)
                        self.books = self.parseJSON(data: data1)
                        self.filtered = self.books
                        self.bookMap = self.buildMap()
                        self.index = self.buildIndex()
                        _ = BibleDB.shared.storeTableContents(bible: bible, books: self.books)
                        print("*** TableContentsModel.AWS load duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
                    }
            })
        } else {
            self.filtered = self.books
            self.bookMap = self.buildMap()
            self.index = self.buildIndex()
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
                            lastChapter: chapters[bookId] ?? 0)
            books.append(book)
        }
        return books
    }
    
    private func buildMap() -> [String:Book] {
        var map = [String:Book]()
        for book in self.books {
            map[book.bookId] = book
        }
        return map
    }
    
    private func buildIndex() -> [String] {
        var idxSet = Set<String>()
        for book in books {
            idxSet.insert(String(book.name.prefix(1)))
        }
        return Array(idxSet).sorted()
    }
    
    var sideIndex: [String] {
        get { return self.index }
    }
    
    func getBook(bookId: String) -> Book? {
        return self.bookMap[bookId]
    }
    
    var filteredBookCount: Int {
        get { return self.filtered.count }
    }

    func getFilteredBook(row: Int) -> Book? {
        return (row >= 0 && row < self.filtered.count) ? self.filtered[row] : nil
    }

    func generateBookCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let book = self.filtered[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherCell", for: indexPath)
        cell.textLabel?.font = AppFont.sansSerif(style: .subheadline)
        cell.textLabel?.text = book.name
        cell.textLabel?.textColor = AppFont.textColor
        if HistoryModel.shared.current().bookId == book.bookId {
            let alpha = AppFont.nightMode ? 0.2 : 1.0
            cell.backgroundColor = UIColor(red: 0.89, green: 0.98, blue: 0.96, alpha: CGFloat(alpha))
        } else {
            cell.backgroundColor = AppFont.backgroundColor
        }
        cell.selectionStyle = .default
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    
    func filterBooks(letter: String) {
        self.filtered = self.filtered.filter({ $0.name.prefix(1) == letter })
    }
    
    func clearFilteredBooks() {
        self.filtered = self.books
    }
    
    func sortBooksTraditional() {
        self.filtered = self.books.sorted(by: { $0.ordinal < $1.ordinal })
    }
    
    func sortBooksAlphabetical() {
        self.filtered = self.books.sorted(by: { $0.name < $1.name })
    }
    
    func nextChapter(reference: Reference) -> Reference {
        if var book = self.getBook(bookId: reference.bookId) {
            if reference.chapter < book.lastChapter {
                return Reference(bibleId: reference.bibleId, bookId: reference.bookId,
                                 chapter: reference.chapter + 1)
            } else {
                if let next = self.getBook(row: book.ordinal + 1) {
                    book = next
                } else {
                    book = self.getBook(row: 0)!
                }
                let chapter = (book.lastChapter > 0) ? 1 : 0
                return Reference(bibleId: reference.bibleId, bookId: book.bookId, chapter: chapter)
            }
        } else {
            return TableContentsDefault.nextChapter(reference: reference)
        }
    }
    
    func priorChapter(reference: Reference) -> Reference {
        if reference.chapter > 1 {
            return Reference(bibleId: reference.bibleId, bookId: reference.bookId,
                             chapter: reference.chapter - 1)
        } else {
            if let book = self.getBook(bookId: reference.bookId) {
                if let prior = self.getBook(row: book.ordinal - 1) {
                    return Reference(bibleId: reference.bibleId, bookId: prior.bookId,
                                     chapter: prior.lastChapter)
                } else {
                    let last = self.books.last!
                    return Reference(bibleId: reference.bibleId, bookId: last.bookId,
                                     chapter: last.lastChapter)
                }
            } else {
                return TableContentsDefault.priorChapter(reference: reference)
            }
        }
    }
    
    private func getBook(row: Int) -> Book? {
        return (row >= 0 && row < self.books.count) ? self.books[row] : nil
    }
}
