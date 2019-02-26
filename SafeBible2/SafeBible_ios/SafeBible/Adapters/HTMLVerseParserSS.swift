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
    private var insideFootnote: Int
    private var stack: [String]
    private var result: [String]
    private var parser: XMLParser?
    
    init(html: String, startVerse: Int, endVerse: Int) {
        self.html = html.replacingOccurrences(of: "&nbsp;", with: "&#160;")
        self.startVerse = startVerse
        self.endVerse = endVerse + 1
        self.insideVerses = false
        self.insideFootnote = 0
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
            print("SS VerseParser DONE")
        }
        return result.joined().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        self.stack.append(elementName)
        //let tabs = String(repeating: "  ", count: self.stack.count)
        //print("**\(tabs)<\(elementName)>")
        if elementName == "span" {
            if let id:String = attributeDict["id"] {
                let parts = id.split(separator: ":")
                if let verse = (parts.count > 2) ? Int(parts[2].split(separator: "-")[0]) : nil {
                    if !self.insideVerses && verse == self.startVerse {
                        self.insideVerses = true
                    }
                    if self.insideVerses && verse >= self.endVerse {
                        self.parser!.abortParsing()
                    }
                }
            }
            if let clas:String = attributeDict["class"] {
                if clas == "topx" || clas == "topf" {
                    self.insideFootnote = stack.count
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        //let tabs = String(repeating: "  ", count: self.stack.count)
        //print("**\(tabs)</\(elementName)>")
        if self.insideFootnote == self.stack.count {
            self.insideFootnote = 0
        }
        let last = self.stack.popLast()
        if last != elementName {
            print("XML element mismatch error \(elementName)")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.insideVerses && self.insideFootnote == 0 {
            self.result.append(string)
        }
        //if self.insideVerses {
        //    print("Inside verse |\(string)|")
        //}
        //else if self.insideFootnote > 0 {
        //    print("Exlude footnote |\(string)|")
        //}
        //else {
        //    let str = string.trimmingCharacters(in: .whitespacesAndNewlines)
        //    if str.count > 0 {
        //        let tabs = String(repeating: "  ", count: self.stack.count + 1)
        //        print("**\(tabs)\(string.trimmingCharacters(in: .whitespacesAndNewlines))")
        //    }
        //}
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        let err = parseError as NSError
        if err.code != 512 {
            print("ERROR: \(parseError)")
        }
    }
}
