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
    
    private let shortsandCSS: String
    private let dbpCSS: String
    
    init() {
        let measure = Measurement()
        let bundle: Bundle = Bundle.main
        let dbpPath = bundle.path(forResource: "www/DBP_FCBH", ofType: "css")
        let ssPath = bundle.path(forResource: "www/ShortSands", ofType: "css")
        let dbpUrl = URL(fileURLWithPath: dbpPath!)
        let ssUrl = URL(fileURLWithPath: ssPath!)
        do {
            self.dbpCSS = try String(contentsOf: dbpUrl)
        } catch let err {
            print("ERROR: DynamicCSS.init() Loading BibleApp2.css \(err)")
            self.dbpCSS = ""
        }
        do {
            self.shortsandCSS = try String(contentsOf: ssUrl)
        } catch let err {
            print("ERROR: DynamicCSS.init() Loading Codex.css \(err)")
            self.shortsandCSS = ""
        }
        measure.duration(location: "Load CSS")
    }
    
    var fontSize: RuleSet {
        get {
            let font = AppFont.serif(style: .body)
            return RuleSet(selector: "html", declaration: "font-size:\(Int(font.pointSize))pt;")
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
    
    var verseNumbersDBP: RuleSet {
        get {
            let verse = AppFont.verseNumbers ? "inline" : "none"
            let verseDecl = "display:\(verse);"
            return RuleSet(selector: ".v-num", declaration: verseDecl)
        }
    }
    
    var verseNumbersSS: RuleSet {
        get {
            let verse = AppFont.verseNumbers ? "inline" : "none"
            let verseDecl = "display:\(verse);"
            return RuleSet(selector: ".v", declaration: verseDecl)
        }
    }
    
    func getEmptyHtml() -> String {
        return "<html><head><style type='text/css'>" + nightMode.genCSS() + "</style>"
            + "<meta name=\"viewport\" content=\"viewport-fit=cover\" />"
            + "</head><body></body></html>"
    }
    
    func wrapHTML(html: String, isShortsands: Bool) -> String {
        if isShortsands {
            let css = self.shortsandCSS
                + self.fontSize.genCSS()
                + self.lineHeight.genCSS()
                + self.nightMode.genCSS()
                + self.verseNumbersSS.genCSS()
            return "<html><head>"
                + "<meta charset=\"utf-8\"/>\n"
                + "<meta name='viewport' content='width=device-width, initial-scale=1.0, user-scalable=no'/>\n"
                + "<style type=\"text/css\">\(css)</style></head>\n"
                + "<body>\(html)</body></html>"
        } else {
            let css = self.dbpCSS
                + self.fontSize.genCSS()
                + self.lineHeight.genCSS()
                + self.nightMode.genCSS()
                + self.verseNumbersDBP.genCSS()
            return "<style type='text/css'>\(css)</style>\(html)"
        }
    }
}
