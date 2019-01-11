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
    private var bookMap: [String:Book]
    private var index: [String]
    private var filtered: [Book]
    
    init(bible: Bible) {
        print("****** init TableContentsModel \(bible.bibleId) ******")
        self.bible = bible
        self.books = [Book]()
        self.bookMap = [String:Book]()
        self.index = [String]()
        self.filtered = [Book]()
        let start: Double = CFAbsoluteTimeGetCurrent()
        self.books = BibleDB.shared.getTableContents(bibleId: bible.bibleId)
        if self.books.count < 1 {
            AwsS3Manager.findDbp().downloadData(s3Bucket: "dbp-prod",
                                       s3Key: "\(self.bible.s3TextPrefix)info.json",
                                       complete: { error, data in
                                        if let data1 = data {
                                            print(data1)
                                            self.books = self.parseJSON(data: data1)
                                            self.bookMap = self.buildMap()
                                            self.index = self.buildIndex()
                                            _ = BibleDB.shared.storeTableContents(bibleId: bible.bibleId,
                                                                                  books: self.books)
                                            print("*** TableContentsModel.AWS load duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
                                        }
            })
        } else {
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
                            lastChapter: chapters[bookId] ?? 1)
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
    
    var bookCount: Int {
        get { return (self.filtered.count > 0) ? self.filtered.count : self.books.count }
    }
    
    func getBook(row: Int) -> Book? {
        if self.filtered.count > 0 {
            return (row >= 0 && row < self.filtered.count) ? self.filtered[row] : nil
        } else {
            return (row >= 0 && row < self.books.count) ? self.books[row] : nil
        }
    }

    func getBook(bookId: String) -> Book? {
        return self.bookMap[bookId]
    }

    func generateBookCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let book = (self.filtered.count > 0) ? self.filtered[indexPath.row] : self.books[indexPath.row]
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
        self.filtered = self.books.filter({ $0.name.prefix(1) == letter })
    }
    
    func clearFilteredBooks() {
        self.filtered.removeAll()
    }
    
    func sortBooksTraditional() {
        self.books = self.books.sorted(by: { $0.ordinal < $1.ordinal })
    }
    
    func sortBooksAlphabetical() {
        self.books = self.books.sorted(by: { $0.name < $1.name })
    }
    
    func nextChapter(reference: Reference) -> Reference {
        let book = self.getBook(bookId: reference.bookId)!
        if reference.chapter < book.lastChapter {
            return Reference(bibleId: reference.bibleId, bookId: reference.bookId,
                             chapter: reference.chapter + 1)
        } else {
            if let next = self.getBook(row: book.ordinal + 1) {
                return Reference(bibleId: reference.bibleId, bookId: next.bookId, chapter: 1)
            } else {
                let first = self.getBook(row: 0)!
                return Reference(bibleId: reference.bibleId, bookId: first.bookId, chapter: 1)
            }
        }
    }
    
    func priorChapter(reference: Reference) -> Reference {
        if reference.chapter > 1 {
            return Reference(bibleId: reference.bibleId, bookId: reference.bookId,
                             chapter: reference.chapter - 1)
        } else {
            let book = self.getBook(bookId: reference.bookId)!
            if let prior = self.getBook(row: book.ordinal - 1) {
                return Reference(bibleId: reference.bibleId, bookId: prior.bookId,
                                 chapter: prior.lastChapter)
            } else {
                let last = self.getBook(row: self.bookCount - 1)!
                return Reference(bibleId: reference.bibleId, bookId: last.bookId,
                                 chapter: last.lastChapter)
            }
        }
    }
}
