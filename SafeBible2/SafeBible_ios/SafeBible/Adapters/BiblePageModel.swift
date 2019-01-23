//
//  BiblePageModel.swift
//  Settings
//
//  Created by Gary Griswold on 10/25/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

// Bible.objectKey contains codes that define String replacements
// %I := Id in last part of s3KeyPrefix
// %O := ordinal 1 is GEN, 70 is MAT, not zero filled
// %o := 3 char ordinal A01 is GEN, zero filled
// %B := USFM 3 char book code
// %b := 2 char book code
// %C := chapter number, not zero filled
// %c := chapter number, zero filled, 2 char, 3 Psalms
//

import AWS
import WebKit

struct BiblePageModel {
    
    func loadPage(reference: Reference, webView: WKWebView) {
        self.getChapter(reference: reference, view: webView, complete: { html in
            if html != nil {
                webView.loadHTMLString(DynamicCSS.shared.getCSS() + html!, baseURL: nil)
            }
        })
    }
    
    func loadCompareVerseCell(reference: Reference, startVerse: Int, endVerse: Int,
                  cell: CompareVerseCell, table: UITableView, indexPath: IndexPath) {
        self.getChapter(reference: reference, view: cell.contentView, complete: { html in
            if html != nil {
                let parser = HTMLVerseParser(html: html!, startVerse: startVerse, endVerse: endVerse)
                cell.verse.text = parser.parseVerses()
                table.reloadRows(at: [indexPath], with: .automatic)
            }
        })
    }
    
    /**
    * I guess the correct way to pass back a string is to pass in a Writable Key Path, but I don't understand it.
    */
    func loadLabel(reference: Reference, verse: Int, label: UILabel) {
        self.getChapter(reference: reference, view: nil, complete: { html in
            if html != nil {
                let parser = HTMLVerseParser(html: html!, startVerse: verse, endVerse: verse)
                var result = parser.parseVerses()
                result = result.replacingOccurrences(of: String(verse), with: "")
                label.text = result.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        })
    }
    
    private func getChapter(reference: Reference, view: UIView?, complete: @escaping (_ data:String?) -> Void) {
        let start = CFAbsoluteTimeGetCurrent()
        let html = BibleDB.shared.getBiblePage(reference: reference)
        if html == nil {
            let progress = self.addProgressIndicator(view: view)
            let s3Key = self.generateKey(reference: reference)
            AwsS3Manager.findDbp().downloadText(s3Bucket: "dbp-prod", s3Key: s3Key,
                                                complete: { error, data in
                                                    self.removeProgressIndicator(indicator: progress)
                                                    if let err = error {
                                                        print("ERROR: \(err)")
                                                        complete(nil)
                                                    }
                                                    else if let data1 = data {
                                                        complete(data1)
                                                        print("AWS Load \(reference.toString())")
                                                        _ = BibleDB.shared.storeBiblePage(reference: reference, html: data1)
                                                        print("*** BiblePageModel.getChapter duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
                                                    }
            })
        } else {
            complete(html)
            print("DB Load \(reference.toString())")
        }
    }
    
    private func addProgressIndicator(view: UIView?) -> UIActivityIndicatorView? {
        if view != nil {
            let style: UIActivityIndicatorView.Style = AppFont.nightMode ? .white : .gray
            let progress = UIActivityIndicatorView(style: style)
            progress.frame = CGRect(x: 40, y: 40, width: 0, height: 0)
            view!.addSubview(progress)
            progress.startAnimating()
            return progress
        } else {
            return nil
        }
    }

    private func removeProgressIndicator(indicator: UIActivityIndicatorView?) {
        if indicator != nil {
            indicator!.stopAnimating()
            indicator!.removeFromSuperview()
        }
    }

    private func generateKey(reference: Reference) -> String {
        var result = [String]()
        var inItem = false
        for char: Character in reference.s3TextTemplate {
            if char == "%" {
                inItem = true
            } else if !inItem {
                result.append(String(char))
            } else {
                inItem = false
                switch char {
                case "I": // Id is last part of s3KeyPrefix
                    let parts = reference.s3TextPrefix.split(separator: "/")
                    result.append(String(parts[parts.count - 1]))
                case "O": // ordinal 1 is GEN, 70 is MAT, not zero filled
                    if let seq = bookMap[reference.bookId]?.seq {
                        result.append(seq)
                    }
                case "o": // 3 char ordinal A01 is GEN, zero filled
                    if let seq3 = bookMap[reference.bookId]?.seq3 {
                        result.append(seq3)
                    }
                case "B": // USFM 3 char book code
                    result.append(reference.bookId)
                case "b": // 2 char book code
                    if let id2 = bookMap[reference.bookId]?.id2 {
                        result.append(id2)
                    }
                case "C": // chapter number, not zero filled
                    result.append(String(reference.chapter))
                case "d": // chapter number, 2 char zero filled, Psalms 3 char
                    var chapStr = String(reference.chapter)
                    if chapStr.count == 1 {
                        chapStr = "0" + chapStr
                    }
                    if chapStr.count == 2 && reference.bookId == "PSA" {
                        chapStr = "0" + chapStr
                    }
                    result.append(chapStr)
                default:
                    print("ERROR: Unknown format char %\(char)")
                }
            }
        }
        return reference.s3TextPrefix + result.joined()
    }

    struct BookData {
        let seq: String
        let seq3: String
        let id2: String
    }

    let bookMap: [String: BookData] = [
        "FRT": BookData(seq: "0", seq3: "?", id2: "?"),
        "GEN": BookData(seq: "2", seq3: "A01", id2: "GN"),
        "EXO": BookData(seq: "3", seq3: "A02", id2: "EX"),
        "LEV": BookData(seq: "4", seq3: "A03", id2: "LV"),
        "NUM": BookData(seq: "5", seq3: "A04", id2: "NU"),
        "DEU": BookData(seq: "6", seq3: "A05", id2: "DT"),
        "JOS": BookData(seq: "7", seq3: "A06", id2: "JS"),
        "JDG": BookData(seq: "8", seq3: "A07", id2: "JG"),
        "RUT": BookData(seq: "9", seq3: "A08", id2: "RT"),
        "1SA": BookData(seq: "10", seq3: "A09", id2: "S1"),
        "2SA": BookData(seq: "11", seq3: "A10", id2: "S2"),
        "1KI": BookData(seq: "12", seq3: "A11", id2: "K1"),
        "2KI": BookData(seq: "13", seq3: "A12", id2: "K2"),
        "1CH": BookData(seq: "14", seq3: "A13", id2: "R1"),
        "2CH": BookData(seq: "15", seq3: "A14", id2: "R2"),
        "EZR": BookData(seq: "16", seq3: "A15", id2: "ER"),
        "NEH": BookData(seq: "17", seq3: "A16", id2: "NH"),
        "EST": BookData(seq: "18", seq3: "A17", id2: "ET"),
        "JOB": BookData(seq: "19", seq3: "A18", id2: "JB"),
        "PSA": BookData(seq: "20", seq3: "A19", id2: "PS"),
        "PRO": BookData(seq: "21", seq3: "A20", id2: "PR"),
        "ECC": BookData(seq: "22", seq3: "A21", id2: "EC"),
        "SNG": BookData(seq: "23", seq3: "A22", id2: "SS"),
        "ISA": BookData(seq: "24", seq3: "A23", id2: "IS"),
        "JER": BookData(seq: "25", seq3: "A24", id2: "JR"),
        "LAM": BookData(seq: "26", seq3: "A25", id2: "LM"),
        "EZK": BookData(seq: "27", seq3: "A26", id2: "EK"),
        "DAN": BookData(seq: "28", seq3: "A27", id2: "DN"),
        "HOS": BookData(seq: "29", seq3: "A28", id2: "HS"),
        "JOL": BookData(seq: "30", seq3: "A29", id2: "JL"),
        "AMO": BookData(seq: "31", seq3: "A30", id2: "AM"),
        "OBA": BookData(seq: "32", seq3: "A31", id2: "OB"),
        "JON": BookData(seq: "33", seq3: "A32", id2: "JH"),
        "MIC": BookData(seq: "34", seq3: "A33", id2: "MC"),
        "NAM": BookData(seq: "35", seq3: "A34", id2: "NM"),
        "HAB": BookData(seq: "36", seq3: "A35", id2: "HK"),
        "ZEP": BookData(seq: "37", seq3: "A36", id2: "ZP"),
        "HAG": BookData(seq: "38", seq3: "A37", id2: "HG"),
        "ZEC": BookData(seq: "39", seq3: "A38", id2: "ZC"),
        "MAL": BookData(seq: "40", seq3: "A39", id2: "ML"),
        "TOB": BookData(seq: "41", seq3: "?", id2: "?"),
        "JDT": BookData(seq: "42", seq3: "?", id2: "?"),
        "ESG": BookData(seq: "43", seq3: "?", id2: "?"),
        "WIS": BookData(seq: "45", seq3: "?", id2: "?"),
        "SIR": BookData(seq: "46", seq3: "?", id2: "?"),
        "BAR": BookData(seq: "47", seq3: "?", id2: "?"),
        "LJE": BookData(seq: "48", seq3: "?", id2: "?"),
        "S3Y": BookData(seq: "49", seq3: "?", id2: "?"),
        "SUS": BookData(seq: "50", seq3: "?", id2: "?"),
        "BEL": BookData(seq: "51", seq3: "?", id2: "?"),
        "1MA": BookData(seq: "52", seq3: "?", id2: "?"),
        "2MA": BookData(seq: "53", seq3: "?", id2: "?"),
        "1ES": BookData(seq: "54", seq3: "?", id2: "?"),
        "MAN": BookData(seq: "55", seq3: "?", id2: "?"),
        "3MA": BookData(seq: "57", seq3: "?", id2: "?"),
        "4MA": BookData(seq: "59", seq3: "?", id2: "?"),
        "MAT": BookData(seq: "70", seq3: "B01", id2: "MT"),
        "MRK": BookData(seq: "71", seq3: "B02", id2: "MK"),
        "LUK": BookData(seq: "72", seq3: "B03", id2: "LK"),
        "JHN": BookData(seq: "73", seq3: "B04", id2: "JN"),
        "ACT": BookData(seq: "74", seq3: "B05", id2: "AC"),
        "ROM": BookData(seq: "75", seq3: "B06", id2: "RM"),
        "1CO": BookData(seq: "76", seq3: "B07", id2: "C1"),
        "2CO": BookData(seq: "77", seq3: "B08", id2: "C2"),
        "GAL": BookData(seq: "78", seq3: "B09", id2: "GL"),
        "EPH": BookData(seq: "79", seq3: "B10", id2: "EP"),
        "PHP": BookData(seq: "80", seq3: "B11", id2: "PP"),
        "COL": BookData(seq: "81", seq3: "B12", id2: "CL"),
        "1TH": BookData(seq: "82", seq3: "B13", id2: "H1"),
        "2TH": BookData(seq: "83", seq3: "B14", id2: "H2"),
        "1TI": BookData(seq: "84", seq3: "B15", id2: "T1"),
        "2TI": BookData(seq: "85", seq3: "B16", id2: "T2"),
        "TIT": BookData(seq: "86", seq3: "B17", id2: "TT"),
        "PHM": BookData(seq: "87", seq3: "B18", id2: "PM"),
        "HEB": BookData(seq: "88", seq3: "B19", id2: "HB"),
        "JAS": BookData(seq: "89", seq3: "B20", id2: "JM"),
        "1PE": BookData(seq: "90", seq3: "B21", id2: "P1"),
        "2PE": BookData(seq: "91", seq3: "B22", id2: "P2"),
        "1JN": BookData(seq: "92", seq3: "B23", id2: "J1"),
        "2JN": BookData(seq: "93", seq3: "B24", id2: "J2"),
        "3JN": BookData(seq: "94", seq3: "B25", id2: "J3"),
        "JUD": BookData(seq: "95", seq3: "B26", id2: "JD"),
        "REV": BookData(seq: "96", seq3: "B27", id2: "RV"),
        "BAK": BookData(seq: "97", seq3: "?", id2: "?"),
        "GLO": BookData(seq: "106", seq3: "?", id2: "?")
         ]
}
