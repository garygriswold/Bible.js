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
    
    static func export(filename: String, bookId: String?) {
        let export = NotesExportDatabase(filename: filename, bookId: bookId)
        export.picker(url: export.srcFileURL)
    }
    
    let destFileName: String
    let srcFileURL: URL
    let bookId: String?

    init(filename: String, bookId: String?) {
        self.destFileName = filename + ".notes"
        self.srcFileURL = Sqlite3.pathDB(dbname: "Notes.db")
        self.bookId = bookId
        super.init()
    }
    
    func picker(url: URL) {
        let start = CFAbsoluteTimeGetCurrent()
        let manager = FileManager.default
        let tmpURL = URL(fileURLWithPath: self.destFileName, relativeTo: manager.temporaryDirectory)
        let tmpPath = tmpURL.path
        print("TMP PATH2 \(tmpURL.path)")
        do {
            if manager.fileExists(atPath: tmpPath) {
                try manager.removeItem(atPath: tmpPath)
            }
            // close notes before copy
            //try Sqlite3.findDB(dbname: "Notes.db")
            try manager.copyItem(at: self.srcFileURL, to: tmpURL)
            if self.bookId != nil {
                // open database
                // delete where bookId is not equals to book
                // vacuum
                // close db
            } else {
                // close db if necessary
            }
        } catch let err {
            print("ERROR copy Notes.db \(err)")
            return
        }
        print("*** Picker Copy duration \((CFAbsoluteTimeGetCurrent() - start) * 1000) ms")
        let docPicker = UIDocumentPickerViewController(url: tmpURL, in: .exportToService)
        docPicker.delegate = self
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController?.present(docPicker, animated: true, completion: nil)
    }
    
    //
    // UIDocumentPickerDelegate
    //
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        //let url =
        print("Picker did Pick called \(urls)")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Picker is Cancelled, nothing exported")
    }
}

