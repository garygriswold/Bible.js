//
//  HTMLChapterParser.swift
//  Settings
//
//  Created by Gary Griswold on 12/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// https://leaks.wanari.com/2016/08/24/xml-parsing-swift/
// https://developer.apple.com/documentation/foundation/xmlparserdelegate

import Foundation
import UIKit

class HTMLVerseParser : NSObject, XMLParserDelegate {
    
    private let html: String
    private let startVerse: String
    private let endVerse: String
    private var insideVerses: Bool
    private var result: [String]
    
    init(html: String, startVerse: Int, endVerse: Int) {
        self.html = html
        self.startVerse = "verse\(startVerse) "
        self.endVerse = "verse\(endVerse + 1) "
        self.insideVerses = false
        self.result = []
        super.init()
    }
    
    func parseVerses() -> String {
        if let data = html.data(using: .utf8) {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.shouldProcessNamespaces = false
            let ok = parser.parse()
            print("PARSER DONE \(ok)")
        }
        return result.joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if let clas = attributeDict["class"] {
            if !self.insideVerses && clas.contains(self.startVerse) {
                self.insideVerses = true
            }
            if self.insideVerses {
                if clas.contains(self.endVerse) || clas == "footnote" || clas == "footer" {
                    self.insideVerses = false
                }
            }
        }
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
        print("ERROR: \(parseError)")
        //parser.lineNumber
        //parser.columnNumber
    }
}
