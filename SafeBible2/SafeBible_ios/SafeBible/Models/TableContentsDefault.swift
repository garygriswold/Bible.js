//
//  TableContentsDefault.swift
//  SafeBible
//
//  Created by Gary Griswold on 2/17/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

/**
* This struct is a default table of contents that allows the App to do a nextChapter, priorChapter
* calls when a Table of Contents has not yet been built for a Bible.
*/
struct TableContentsDefault {
    
    struct TOCBook : Equatable {
        let bookId: String
        let lastChapter: Int
    
        static func == (lhs: TOCBook, rhs: TOCBook) -> Bool {
            return lhs.bookId == rhs.bookId
        }
    }
    
    static let books: [TOCBook] = [
        TOCBook(bookId: "GEN", lastChapter: 50),
        TOCBook(bookId: "EXO", lastChapter: 40),
        TOCBook(bookId: "LEV", lastChapter: 27),
        TOCBook(bookId: "NUM", lastChapter: 36),
        TOCBook(bookId: "DEU", lastChapter: 34),
        TOCBook(bookId: "JOS", lastChapter: 24),
        TOCBook(bookId: "JDG", lastChapter: 21),
        TOCBook(bookId: "RUT", lastChapter: 4),
        TOCBook(bookId: "1SA", lastChapter: 31),
        TOCBook(bookId: "2SA", lastChapter: 24),
        TOCBook(bookId: "1KI", lastChapter: 22),
        TOCBook(bookId: "2KI", lastChapter: 25),
        TOCBook(bookId: "1CH", lastChapter: 29),
        TOCBook(bookId: "2CH", lastChapter: 36),
        TOCBook(bookId: "EZR", lastChapter: 10),
        TOCBook(bookId: "NEH", lastChapter: 13),
        TOCBook(bookId: "EST", lastChapter: 10),
        TOCBook(bookId: "JOB", lastChapter: 42),
        TOCBook(bookId: "PSA", lastChapter: 150),
        TOCBook(bookId: "PRO", lastChapter: 31),
        TOCBook(bookId: "ECC", lastChapter: 12),
        TOCBook(bookId: "SNG", lastChapter: 8),
        TOCBook(bookId: "ISA", lastChapter: 66),
        TOCBook(bookId: "JER", lastChapter: 52),
        TOCBook(bookId: "LAM", lastChapter: 5),
        TOCBook(bookId: "EZK", lastChapter: 48),
        TOCBook(bookId: "DAN", lastChapter: 12),
        TOCBook(bookId: "HOS", lastChapter: 14),
        TOCBook(bookId: "JOL", lastChapter: 3),
        TOCBook(bookId: "AMO", lastChapter: 9),
        TOCBook(bookId: "OBA", lastChapter: 1),
        TOCBook(bookId: "JON", lastChapter: 4),
        TOCBook(bookId: "MIC", lastChapter: 7),
        TOCBook(bookId: "NAM", lastChapter: 3),
        TOCBook(bookId: "HAB", lastChapter: 3),
        TOCBook(bookId: "ZEP", lastChapter: 3),
        TOCBook(bookId: "HAG", lastChapter: 2),
        TOCBook(bookId: "ZEC", lastChapter: 14),
        TOCBook(bookId: "MAL", lastChapter: 4),
        TOCBook(bookId: "MAT", lastChapter: 28),
        TOCBook(bookId: "MRK", lastChapter: 16),
        TOCBook(bookId: "LUK", lastChapter: 24),
        TOCBook(bookId: "JHN", lastChapter: 21),
        TOCBook(bookId: "ACT", lastChapter: 28),
        TOCBook(bookId: "ROM", lastChapter: 16),
        TOCBook(bookId: "1CO", lastChapter: 16),
        TOCBook(bookId: "2CO", lastChapter: 13),
        TOCBook(bookId: "GAL", lastChapter: 6),
        TOCBook(bookId: "EPH", lastChapter: 6),
        TOCBook(bookId: "PHP", lastChapter: 4),
        TOCBook(bookId: "COL", lastChapter: 4),
        TOCBook(bookId: "1TH", lastChapter: 5),
        TOCBook(bookId: "2TH", lastChapter: 3),
        TOCBook(bookId: "1TI", lastChapter: 6),
        TOCBook(bookId: "2TI", lastChapter: 4),
        TOCBook(bookId: "TIT", lastChapter: 3),
        TOCBook(bookId: "PHM", lastChapter: 1),
        TOCBook(bookId: "HEB", lastChapter: 13),
        TOCBook(bookId: "JAS", lastChapter: 5),
        TOCBook(bookId: "1PE", lastChapter: 5),
        TOCBook(bookId: "2PE", lastChapter: 3),
        TOCBook(bookId: "1JN", lastChapter: 5),
        TOCBook(bookId: "2JN", lastChapter: 1),
        TOCBook(bookId: "3JN", lastChapter: 1),
        TOCBook(bookId: "JUD", lastChapter: 1),
        TOCBook(bookId: "REV", lastChapter: 22)
    ]
    
    static func nextChapter(reference: Reference) -> Reference {
        let curr = TOCBook(bookId: reference.bookId, lastChapter: 0)
        if let index = books.index(of: curr) {
            let book = books[index]
            if reference.chapter < book.lastChapter {
                return Reference(bibleId: reference.bibleId, bookId: reference.bookId,
                                 chapter: reference.chapter + 1)
            } else {
                if index < (books.count - 1) {
                    let next = books[index + 1]
                    return Reference(bibleId: reference.bibleId, bookId: next.bookId, chapter: 1)
                } else {
                    let matt = books.index(of: TOCBook(bookId: "MAT", lastChapter: 0))
                    return Reference(bibleId: reference.bibleId, bookId: books[matt!].bookId, chapter: 1)
                }
            }
        } else {
            // This can occur if a user is on a book that is not in the books array
            return reference
        }
    }
    
    static func priorChapter(reference: Reference) -> Reference {
        if reference.chapter > 1 {
            return Reference(bibleId: reference.bibleId, bookId: reference.bookId,
                             chapter: reference.chapter - 1)
        } else {
            let curr = TOCBook(bookId: reference.bookId, lastChapter: 0)
            if let index = books.index(of: curr) {
                let matt = books.index(of: TOCBook(bookId: "MAT", lastChapter: 0))!
                if index > matt {
                    let prior = books[index - 1]
                    return Reference(bibleId: reference.bibleId, bookId: prior.bookId,
                                     chapter: prior.lastChapter)
                } else {
                    let last = books.last!
                    return Reference(bibleId: reference.bibleId, bookId: last.bookId,
                                     chapter: last.lastChapter)
                }
            } else {
                // This can occur if a user is on a book that is not in the books array
                return reference
            }
        }
    }
}
