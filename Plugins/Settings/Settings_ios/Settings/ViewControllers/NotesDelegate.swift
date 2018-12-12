//
//  NotesDelegate.swift
//  Settings
//
//  Created by Gary Griswold on 12/11/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import WebKit

class NotesDelegate : NSObject, WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let noteId = message.body as? String {
            if message.name == "book" {
                print("click on book")
            }
            else if message.name == "note" {
                print("click on note")
            }
        }
    }
    
}
