//
//  NotesDocument.swift
//  Settings
//
//  Created by Gary Griswold on 12/15/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/DocumentBasedAppPGiOS/CreateCustomDocument/CreateCustomDocument.html

import UIKit

class NotesExportDocument : UIDocument, UIDocumentPickerDelegate {
    
    static func export(filename: String, bookId: String?, button: UIBarButtonItem?) {
        let export = NotesExportDocument(filename: filename, bookId: bookId, button: button)
        export.save(to: export.fileURL, for: .forCreating, completionHandler: { (Bool) in
            print("file is saved \(export.fileURL)")
            export.share(url: export.fileURL)
        })
    }
    
    let bookId: String?
    private weak var button: UIBarButtonItem?
    
    init(filename: String, bookId: String?, button: UIBarButtonItem?) {
        let rootUrl = FileManager.default.temporaryDirectory
        let url = rootUrl.appendingPathComponent(filename + ".txt")
        self.bookId = bookId
        self.button = button
        super.init(fileURL: url)
    }
    
    //Override this method to load the document data into the app’s data model.
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        let data: Data = contents as! Data
        if let msg = String(data: data, encoding: .utf8) {
            print("message: \(msg)")
        }
    }
    
    //Override this method to return the document data to be saved.
    override func contents(forType typeName: String) throws -> Any {
        var contents = [String]()
        let notes = NotesDB.shared.getNotes(bookId: self.bookId, note: true, lite: false, book: false)
        for note in notes {
            if note.note {
                contents.append("\n")
                let reference = note.getReference()
                let passage = reference.description(startVerse: note.startVerse, endVerse: note.endVerse)
                contents.append(passage)
                contents.append(note.text!)
            }
        }
        let data = contents.joined(separator: "\n").data(using: .utf8)
        return data!
    }
    
    func share(url: URL) {
        let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        share.popoverPresentationController?.barButtonItem = self.button  // so that iPads won't crash
        //share.excludedActivityTypes = [.copyToPasteboard, .openInIBooks, .postToFacebook,
        //                               .postToTencentWeibo, .postToTwitter, .postToWeibo, .print,
        //                               .markupAsPDF]
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController!.present(share, animated: true, completion: nil)
    }

}
