//
//  NotesExportDatabase.swift
//  Settings
//
//  Created by Gary Griswold on 12/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import MessageUI

class NotesExportDatabase : UIDocument, MFMailComposeViewControllerDelegate {
    
    static let notesFileType = "com.shortsands.notes"
    
    static func export(filename: String, bookId: String?) {
        if MFMailComposeViewController.canSendMail() {
            let export = NotesExportDatabase(filename: filename, bookId: bookId)
            export.save(to: export.fileURL, for: .forCreating, completionHandler: { (Bool) in
                print("file is saved \(export.fileURL)")
                export.share(url: export.fileURL)
            })
        } else {
            print("ERROR: Mail services are not available")
            /// Do I need an alert popup here?
        }
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
            let dbURL = NotesDB.shared.pathDB(dbname: NotesDB.shared.currentDB)
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
        let compose = MFMailComposeViewController()
        compose.mailComposeDelegate = self
        do {
            let data = try Data(contentsOf: url)
            compose.addAttachmentData(data,
                                      mimeType: "application/vnd.sqlite3",
                                      fileName: url.lastPathComponent)
        
            let rootController = UIApplication.shared.keyWindow?.rootViewController
            rootController!.present(compose, animated: true, completion: nil)
        } catch let err {
            print("ERROR NotesExportDatabase.share \(err)")
        }
    }
    //
    // Delegate
    //
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

