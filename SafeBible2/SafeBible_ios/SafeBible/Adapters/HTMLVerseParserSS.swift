//
//  HTMLChapterParserSS.swift
//  Settings
//
//  Created by Gary Griswold on 12/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// https://leaks.wanari.com/2016/08/24/xml-parsing-swift/
// https://developer.apple.com/documentation/foundation/xmlparserdelegate

import Foundation
import UIKit

/*
* This class parses verses that come from shortsands buckets.
*/
class HTMLVerseParserSS : NSObject, XMLParserDelegate {
    
    private let html: String
    private let startVerse: Int
    private let endVerse: Int
    private var insideVerses: Bool
    private var result: [String]
    
    init(html: String, startVerse: Int, endVerse: Int) {
        self.html = html.replacingOccurrences(of: "&nbsp;", with: "&#160;")
        self.startVerse = startVerse
        self.endVerse = endVerse + 1
        self.insideVerses = false
        self.result = []
        super.init()
    }
    
    func parseVerses() -> String {
        if let data = self.html.data(using: .utf8) {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.shouldProcessNamespaces = false
            let ok = parser.parse()
            print("SS VerseParser DONE \(ok)")
        }
        return result.joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        if elementName == "span" {
            if let id:String = attributeDict["id"] {
                let parts = id.split(separator: ":")
                if let verse = (parts.count > 2) ? Int(parts[2]) : nil {
                    if !self.insideVerses && verse == self.startVerse {
                        self.insideVerses = true
                    }
                    if self.insideVerses && verse == self.endVerse {
                        self.insideVerses = false
                    }
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.insideVerses {
            self.result.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("ERROR: \(parseError)")
        //parser.lineNumber
        //parser.columnNumber
    }
}
