//
//  NotesExportDatabase.swift
//  Settings
//
//  Created by Gary Griswold on 12/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import Utility

class NotesExportDatabase : UIDocument {
    
    static let notesFileType = "com.shortsands.notes"
    
    static func export(filename: String, bookId: String?) {
        let export = NotesExportDatabase(filename: filename, bookId: bookId)
        export.save(to: export.fileURL, for: .forCreating, completionHandler: { (Bool) in
            print("file is saved \(export.fileURL)")
            export.share(url: export.fileURL)
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
        if self.bookId == nil {
            let dbURL = Sqlite3.pathDB(dbname: "Notes.notes")
            let data = try Data(contentsOf: dbURL)
            return data
        } else {
            let folderURL = self.fileURL.deletingLastPathComponent()
            let tmpURL = folderURL.appendingPathComponent("NotesTmp.notes")
            NotesDB.shared.copyBookNotes(url: tmpURL, bookId: self.bookId!)
            let data = try Data(contentsOf: tmpURL)
            return data
        }
    }
    
    func share(url: URL) {
        let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        //share.popoverPresentationController?.sourceView = self//.view // so that iPads won't crash
        share.excludedActivityTypes = [.copyToPasteboard, .openInIBooks, .postToFacebook,
                                       .postToTencentWeibo, .postToTwitter, .postToWeibo, .print,
                                       .markupAsPDF]
        //share.completionWithItemsHandler = #selector(complete)
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController!.present(share, animated: true, completion: nil)
    }
    
    //func complete(_ UIActivity.ActivityType?, Bool, [Any]?, Error?) -> Void) {
    //}
}

