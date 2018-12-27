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
    
    static func export(filename: String, bookId: String?) {
        let export = NotesExportDocument(filename: filename, bookId: bookId)
        export.save(to: export.fileURL, for: .forCreating, completionHandler: { (Bool) in
            print("file is saved \(export.fileURL)")
            export.picker(url: export.fileURL)
        })
    }
    
    let bookId: String?
    
    init(filename: String, bookId: String?) {
        let rootUrl = FileManager.default.temporaryDirectory
        let url = rootUrl.appendingPathComponent(filename + ".txt")
        self.bookId = bookId
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
        let notes = NotesDB.shared.getNotes(bookId: self.bookId, note: true, lite: true, book: true)
        for note in notes {
            if note.note != nil {
                contents.append("\n")
                let reference = note.getReference()
                let passage = reference.description(startVerse: note.startVerse, endVerse: note.endVerse)
                contents.append(passage)
                contents.append(note.note!)
            }
        }
        let data = contents.joined(separator: "\n").data(using: .utf8)
        return data!
    }
    
    func picker(url: URL) {
        let docPicker = UIDocumentPickerViewController(url: url, in: .exportToService)
        docPicker.delegate = self
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController?.present(docPicker, animated: true, completion: nil)
    }
    
    //
    // UIDocumentPickerDelegate
    //
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        print("Picker did Pick called \(urls)")
        //let doc = UIDocumentInteractionController(url: urls[0])
        //doc.presentPreview(animated: true)
        self.interaction(url: urls[0])
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Picker is Cancelled, nothing exported")
    }
    
    private func interaction(url: URL) {
        //let attrs = [NSAttributedString.Key.font: AppFont.serif(style: .body),
        //             NSAttributedString.Key.foregroundColor: UIColor.black]
        //let string = NSAttributedString(string: text, attributes: attrs)
        //let print = UISimpleTextPrintFormatter(attributedText: string)
        
        let share = UIActivityViewController(activityItems: [url],
                                             applicationActivities: nil)
        //share.popoverPresentationController?.sourceView = self//.view // so that iPads won't crash
        share.excludedActivityTypes = nil
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController!.present(share, animated: true, completion: nil)
    }
}
