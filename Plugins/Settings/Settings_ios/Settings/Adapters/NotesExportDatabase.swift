//
//  NotesExportDatabase.swift
//  Settings
//
//  Created by Gary Griswold on 12/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import Utility

class NotesExportDatabase : UIDocument, UIDocumentPickerDelegate {
    
    static let notesFileType = "com.shortsands.notes"
    
    static func export(filename: String, bookId: String?) {
        let export = NotesExportDatabase(filename: filename, bookId: bookId)
        export.save(to: export.fileURL, for: .forCreating, completionHandler: { (Bool) in
            print("file is saved \(export.fileURL)")
            export.picker(url: export.fileURL)
        })
    }
    
    let bookId: String?

    init(filename: String, bookId: String?) {
        let rootUrl = FileManager.default.temporaryDirectory
        let url = rootUrl.appendingPathComponent(filename + ".notes")
        self.bookId = bookId
        super.init(fileURL: url)
    }
    
    override var fileType: String? {
        get { return NotesExportDatabase.notesFileType }
    }
    
    //Override this method to load the document data into the app’s data model.
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        print("NotesExportDatabase.load called")
    }
    
    //Override this method to return the document data to be saved.
    override func contents(forType typeName: String) throws -> Any {
        let measure = Measurement()
        let dbURL = Sqlite3.pathDB(dbname: "Notes.db")
        let data = try Data(contentsOf: dbURL)
        measure.duration(location: "after data")
        return data
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
        //let url =
        print("Picker did Pick called \(urls)")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Picker is Cancelled, nothing exported")
    }
}

