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
        let parts = selection.split(separator: "/")
        let start = parts[0].split(separator: ":")
        let end = parts[1].split(separator: ":")
        self.startClass = String(start[0])
        self.startClassPos = Int(start[1]) ?? 0
        self.startCharPos = Int(start[2]) ?? 0
        self.endClass = String(end[0])
        self.endClassPos = Int(end[1]) ?? 0
        self.endCharPos = Int(end[2]) ?? 0
    }
}
