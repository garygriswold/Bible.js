//
//  ConcordanceResultCell.swift
//  SafeBible
//
//  Created by Gary Griswold on 5/4/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import Foundation
import UIKit

class ConcordanceResultCell : UITableViewCell {
    let title = UILabel()
    let verse = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.title.font = AppFont.sansSerif(style: .subheadline)
        self.contentView.addSubview(self.title)
        
        self.verse.numberOfLines = 0
        self.verse.font = AppFont.serif(style: .body)
        self.contentView.addSubview(self.verse)
        
        let inset = self.contentView.frame.width * 0.05
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        
        self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: inset).isActive = true
        self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: inset).isActive = true
        
        self.verse.translatesAutoresizingMaskIntoConstraints = false
        
        self.verse.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: inset / 2.0).isActive = true
        self.verse.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: inset).isActive = true
        self.verse.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -inset).isActive = true
        self.verse.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -inset).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("ConcordanceResultCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit ConcordanceResultCell ******")
    }
    
    func showLastResult(indexPath: IndexPath, section: Int?) {
        let concordance = ConcordanceModel.shared
        self.contentView.backgroundColor = AppFont.backgroundColor
        
        self.title.textColor = AppFont.textColor
        self.verse.textColor = AppFont.textColor
        
        let bible = HistoryModel.shared.currBible
        
        if indexPath.row < ConcordanceViewController.VIEW_GROUP_SIZE || section != nil {
            let useSection = (section != nil) ? section! : indexPath.section
            let wordRef = concordance.resultsByBook[useSection][indexPath.row]
            let reference = Reference(bibleId: bible.bibleId, bookId: wordRef.bookId,
                                      chapter: Int(wordRef.chapter))
            self.title.text = reference.description(verse: wordRef.verse)
            self.verse.attributedText = self.format(bible: bible, wordRef: wordRef)
            
        } else {
            let wordRefGroup = concordance.resultsByBook[indexPath.section]
            let count = wordRefGroup.count - ConcordanceViewController.VIEW_GROUP_SIZE
            let bookId = wordRefGroup[0].bookId
            let name = bible.tableContents?.getBook(bookId: bookId)?.name
            self.title.text = "\(count) More In \(name ?? bookId)"
            self.verse.text = nil
        }
        self.accessoryType = .disclosureIndicator
    }
    
    private func format(bible: Bible, wordRef: WordRef) -> NSMutableAttributedString? {
        let pointSize = AppFont.serif(style: .body).pointSize * 0.95
        if let verseStr = BibleDB.shared.selectVerse(bible: bible, wordRef: wordRef) {
            let verse = NSMutableAttributedString(string: verseStr)
            let ranges = self.findRanges(string: verseStr, wordPositions: wordRef.wordPositions!)
            for range in ranges {
                verse.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: pointSize), range: range)
            }
            return verse
        } else {
            return nil
        }
    }
    
    private func findRanges(string: String, wordPositions: WordPositions) -> [NSRange] {
        var wordPositions = self.sequencePositions(wordPositions: wordPositions)
        var ranges = [NSRange]()
        var search = wordPositions.remove(at: 0)
        let chars = Array(string)
        var insideWord = false
        var wordStart = 0
        var wordCount: UInt8 = 0
        for index in 0..<chars.count {
            let char: Character = chars[index]
            let unicode = Unicode.Scalar(String(char))
            if unicode != nil && ConcordanceModel.delims.contains(unicode!) {
                if wordCount == search && insideWord {
                    ranges.append(NSRange(location: wordStart, length: index - wordStart))
                    if wordPositions.count > 0 {
                        search = wordPositions.remove(at: 0)
                    } else {
                        return ranges
                    }
                }
                insideWord = false
            } else if !char.isPunctuation {
                if !insideWord {
                    insideWord = true
                    wordStart = index
                    wordCount += 1
                }
            }
        }
        if wordCount == search && insideWord {
            ranges.append(NSRange(location: wordStart, length: chars.count - wordStart))
        }
        return ranges
    }
    
    private func sequencePositions(wordPositions: WordPositions) -> [UInt8] {
        var result = [UInt8]()
        for index in 0..<wordPositions.numWords {
            result += wordPositions.positions[index]
        }
        return result.sorted()
    }
}
