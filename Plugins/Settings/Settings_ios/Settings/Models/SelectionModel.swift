//
//  SelectionModel.swift
//  Settings
//
//  Created by Gary Griswold on 11/22/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import UIKit

struct Selection {
    let startClass: String
    let startClassPos: Int
    let startCharPos: Int
    let endClass: String
    let endClassPos: Int
    let endCharPos: Int
    let midSelection: String?
    
    //init(startClass: String, startClassPos: Int, startCharPos: Int,
    //     endClass: String, endClassPos: Int, endCharPos: Int) {
    //    self.startClass = startClass
    //    self.startClassPos = startClassPos
    //    self.startCharPos = startCharPos
    //    self.endClass = endClass
    //    self.endClassPos = endClassPos
    //    self.endCharPos = endCharPos
    //}
    
    init(selection: String) {
        var parts: [Substring] = selection.split(separator: "/")
        self.startCharPos = Int(parts.remove(at: 0)) ?? 0
        self.endCharPos = Int(parts.remove(at: 0)) ?? 0
        let start = parts.remove(at: 0).split(separator: ":")
        self.startClass = String(start[0])
        self.startClassPos = Int(start[1]) ?? 0
        if parts.count > 0 {
            let end = parts.remove(at: parts.count - 1).split(separator: ":")
            self.endClass = String(end[0])
            self.endClassPos = Int(end[1]) ?? 0
        } else {
            self.endClass = self.startClass
            self.endClassPos = self.startClassPos
        }
        if parts.count > 0 {
            self.midSelection = parts.joined(separator: "/")
        } else {
            self.midSelection = nil
        }
    }
}
