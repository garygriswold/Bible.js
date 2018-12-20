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
    
    static func exportNotesDocument(name: String, notes: [Note]) {
        let export = NotesExportDocument(name: name, notes: notes)
        export.save(to: export.fileURL, for: .forCreating, completionHandler: { (Bool) in
            print("file is saved \(export.fileURL)")
            export.picker(url: export.fileURL)
        })
    }
    
    private let notes: [Note]
    
    init(name: String, notes: [Note]) {
        self.notes = notes
        let rootUrl = FileManager.default.temporaryDirectory
        let url = rootUrl.appendingPathComponent(name + ".txt")
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
        for note in self.notes {
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
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Picker is Cancelled, nothing exported")
    }
}
