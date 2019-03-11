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
    private var insideFootnote: Bool
    private var stack: [String]
    private var result: [String]
    private var parser: XMLParser?
    
    init(html: String, startVerse: Int, endVerse: Int) {
        self.html = html.replacingOccurrences(of: "&nbsp;", with: "&#160;")
        self.startVerse = startVerse
        self.endVerse = endVerse + 1
        self.insideVerses = false
        self.insideFootnote = false
        self.stack = []
        self.result = []
        super.init()
    }
    
    func parseVerses() -> String {
        if let data = self.html.data(using: .utf8) {
            self.parser = XMLParser(data: data)
            self.parser!.delegate = self
            self.parser!.shouldProcessNamespaces = false
            _ = self.parser!.parse()
        }
        return result.joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        let clas = attributeDict["class"]
        if clas == "v" {
            let id:String = attributeDict["id"] ?? "XXX:1:1"
            self.stack.append(id)
            let parts = id.split(separator: ":")
            let verse = (parts.count > 2) ? parts[2].split(separator: "-") : ["0"]
            let verse0: Int = Int(verse[0])!
            let verse1: Int? = (verse.count > 1) ? Int(verse[1])! : nil//-1
            if verse0 == self.startVerse {
                self.insideVerses = true
            }
            if verse1 != nil && verse1! >= self.startVerse && verse1! <= self.endVerse {
                self.insideVerses = true
            }
            if verse0 >= self.endVerse {
                self.parser!.abortParsing()
            }
        }
        else if clas == "topx" || clas == "topf" {
            self.stack.append(clas!)
            self.insideFootnote = true
        } else {
            self.stack.append(elementName)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        let last = self.stack.popLast()
        if last == "topf" || last == "topx" {
            self.insideFootnote = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.insideVerses && !self.insideFootnote {
            self.result.append(string)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        let err = parseError as NSError
        if err.code != 512 {
            print("ERROR: \(parseError)")
        }
    }
}
