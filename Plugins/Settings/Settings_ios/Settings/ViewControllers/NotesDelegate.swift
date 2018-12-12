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
            if let note = SettingsDB.shared.getNote(noteId: noteId) {
                if message.name == "book" {
                    self.bookmarkAlert(note: note)
                }
                else if message.name == "note" {
                    NoteViewController.present(note: note)
                }
            }
        }
    }
    
    private func bookmarkAlert(note: Note) {
        let reference = note.getReference()
        let passage = reference.description(startVerse: note.startVerse, endVerse: note.endVerse)
        let alert = UIAlertController(title: passage, message: "Bookmark", preferredStyle: .alert)
        let okString = NSLocalizedString("OK", comment: "Default action")
        let ok = UIAlertAction(title: okString, style: .default, handler: nil)
        alert.addAction(ok)
        let deleteString = NSLocalizedString("Delete", comment: "Delete bookmark action")
        let delete = UIAlertAction(title: deleteString, style: .destructive, handler: { _ in
            print("inside delete choice")
        })
        alert.addAction(delete)
        alert.preferredAction = ok
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController!.present(alert, animated: true, completion: nil)
    }
}
