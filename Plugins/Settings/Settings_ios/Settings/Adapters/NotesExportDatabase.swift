//
//  NotesExportDatabase.swift
//  Settings
//
//  Created by Gary Griswold on 12/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import Utility

class NotesExportDatabase : NSObject, UIDocumentPickerDelegate {
    
    static func exportNotesDatabase(name: String) {
        let export = NotesExportDatabase(name: name)
        export.picker(url: export.srcFileURL)
    }
    
    let destFileName: String
    let srcFileURL: URL

    init(name: String) {
        self.destFileName = name + ".safe_notes_db"
        self.srcFileURL = Sqlite3.pathDB(dbname: "Notes.db")
        super.init()
    }
    
    // UTI public.database
    func picker(url: URL) {
        let start = CFAbsoluteTimeGetCurrent()
        let tmpDir = FileManager.default.temporaryDirectory
        let tmpURL = URL(fileURLWithPath: self.destFileName, relativeTo: tmpDir)
        do {
            try FileManager.default.copyItem(at: self.srcFileURL, to: tmpURL)
            // How do I close database while in tmp
            // What do I do about thumbnail
        } catch let err {
            print("ERROR copy Notes.db \(err)")
            return
        }
        print("*** Picker Copy duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
        let docPicker = UIDocumentPickerViewController(url: tmpURL, in: .exportToService)
        docPicker.delegate = self
        docPicker.modalPresentationStyle = UIModalPresentationStyle.formSheet // optional
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController?.present(docPicker, animated: true, completion: nil)
    }
    
    //
    // UIDocumentPickerDelegate
    //
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        let url =
        print("Picker did Pick called \(urls)")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Picker is Cancelled, nothing exported")
    }
}

