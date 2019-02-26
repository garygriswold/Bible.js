//
//  HTMLChapterParserDBP.swift
//  Settings
//
//  Created by Gary Griswold on 12/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// https://leaks.wanari.com/2016/08/24/xml-parsing-swift/
// https://developer.apple.com/documentation/foundation/xmlparserdelegate

import Foundation
import UIKit

/**
* This parses verses that come from FCBH's Digital Bible Platform.
*/
class HTMLVerseParserDBP : NSObject, XMLParserDelegate {
    
    private let html: String
    private let startVerse: Int
    private let endVerse: Int
    private var insideVerses: Bool
    private var result: [String]
    private var parser: XMLParser?
    
    init(html: String, startVerse: Int, endVerse: Int) {
        self.html = html
        self.startVerse = startVerse
        self.endVerse = endVerse + 1
        self.insideVerses = false
        self.result = []
        super.init()
    }
    
    func parseVerses() -> String {
        if let data = self.html.data(using: .utf8) {
            self.parser = XMLParser(data: data)
            self.parser!.delegate = self
            self.parser!.shouldProcessNamespaces = false
            _ = self.parser!.parse()
            print("DBP VerseParser DONE")
        }
        return result.joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if let clas = attributeDict["class"] {
            if let verse = self.getVerseNum(clas: clas) {
                if !self.insideVerses && verse == self.startVerse {
                    self.insideVerses = true
                }
                if self.insideVerses {
                    if verse >= self.endVerse || clas == "footnote" || clas == "footer" {
                        self.parser!.abortParsing()
                        
                    }
                }
            }
        }
    }
    
    private func getVerseNum(clas: String) -> Int? {
        if clas.starts(with: "verse") {
            let versePart = clas.split(separator: " ")[0]
            let index = versePart.index(versePart.startIndex, offsetBy: 5)
            let part = versePart[index...]
            return Int(part)
        }
        return nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.insideVerses {
            if string == "\u{00A0}" {
                self.result.append(" ")
            } else {
                self.result.append(string)
            }
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        let err = parseError as NSError
        if err.code != 512 {
            print("ERROR: \(parseError)")
        }
    }
}
