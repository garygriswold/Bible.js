//
//  SelectionModel.swift
//  Settings
//
//  Created by Gary Griswold on 11/22/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import UIKit

struct Selection {
    
    static var current: Selection?
    
    let startClass: String
    let startClassPos: Int
    let startCharPos: Int
    let endClass: String? // nil if same as start
    let endClassPos: Int? // nil if same as start
    let endCharPos: Int
    let midSelection: String?
    
    static func factory(selection: String) -> Selection {
        var parts: [Substring] = selection.split(separator: "/")
        let startCharPos = Int(parts.remove(at: 0)) ?? 0
        let endCharPos = Int(parts.remove(at: 0)) ?? 0
        let start = parts.remove(at: 0).split(separator: ":")
        let startClass = String(start[0])
        let startClassPos = Int(start[1]) ?? 0
        let end = (parts.count > 0) ? parts.remove(at: parts.count - 1).split(separator: ":") : nil
        let endClass = (end != nil) ? String(end![0]) : nil
        let endClassPos = (end != nil) ? Int(end![1]) ?? 0 : nil
        let midSelection = (parts.count > 0) ? parts.joined(separator: "/") : nil
        Selection.current = Selection(startClass: startClass, startClassPos:
            startClassPos, startCharPos: startCharPos, endClass: endClass, endClassPos: endClassPos,
                           endCharPos: endCharPos, midSelection: midSelection)
        return Selection.current!
    }
}
