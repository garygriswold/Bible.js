//
//  DynamicCSS.swift
//  Settings
//
//  Created by Gary Griswold on 11/7/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import WebKit

struct DynamicCSS {
    
    static var shared = DynamicCSS()
    
    struct RuleSet {
        let selector: String
        let declaration: String
        
        func genCSS() -> String {
            return "\(selector) { \(declaration) }\n"
        }
        func genRule() -> String {
            return "document.styleSheets[0].addRule('\(selector)', '\(declaration)');\n"
        }
    }
    
    private let cssFile: String
    let baseURL: URL
    
    init() {
        let bundle: Bundle = Bundle.main
        let path = bundle.path(forResource: "www/BibleApp2", ofType: "css")
        self.baseURL = URL(fileURLWithPath: path!)
        do {
            self.cssFile = try String(contentsOf: self.baseURL)
        } catch let err {
            print("ERROR: DynamicCSS.init() Loading CSS \(err)")
            self.cssFile = ""
        }
    }
    
    var fontSize: RuleSet {
        get {
            let font = AppFont.serif(style: .body)
            return RuleSet(selector: "html", declaration: "font-size:\(Int(font.pointSize))pt")
        }
    }
    
    var lineHeight: RuleSet {
        get {
            return RuleSet(selector: ".section,.chapter",
                           declaration: "line-height:\(AppFont.bodyLineHeight);")
        }
    }
    
    var nightMode: RuleSet {
        get {
            let colorDecl = AppFont.nightMode ? "background-color:black; color:white;" :
            "background-color:white; color:black;"
            return RuleSet(selector: "html", declaration: colorDecl)
        }
    }
    
    var verseNumbers: RuleSet {
        get {
            let verse = AppFont.verseNumbers ? "inline" : "none"
            let verseDecl = "display:\(verse);"
            return RuleSet(selector: ".v-num", declaration: verseDecl)
        }
    }
    
    func getCSS() -> String {
        return "<style type='text/css'>" +
            cssFile +
            self.fontSize.genCSS() +
            self.lineHeight.genCSS() +
            self.nightMode.genCSS() +
            self.verseNumbers.genCSS() +
        "</style>\n"
    }
    
    func getAllRules() -> String {
        return self.fontSize.genRule() +
            self.lineHeight.genRule() +
            self.nightMode.genRule() +
            self.verseNumbers.genRule()
    }
    
    func getEmptyHtml() -> String {
        return "<html><head><style type='text/css'>" + nightMode.genCSS() + "</style>"
            + "<meta name=\"viewport\" content=\"viewport-fit=cover\" />"
            + "</head><body></body></html>"
    }
}
