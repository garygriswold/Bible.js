//
//  NotesDocument.swift
//  Settings
//
//  Created by Gary Griswold on 12/15/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
// https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/DocumentBasedAppPGiOS/CreateCustomDocument/CreateCustomDocument.html

import Foundation
import UIKit

class NotesExportDocument : UIDocument, UIDocumentPickerDelegate {
    
    private static var icloudRoot: URL?
    
    static func testNotesDocument() {
        DispatchQueue.main.async(execute: {
            let containerID = "iCloud.com.shortsands.settings"
            NotesExportDocument.icloudRoot = FileManager.default.url(forUbiquityContainerIdentifier: containerID)
            if let icloud = NotesExportDocument.icloudRoot {
                testNotesDocument2(rootUrl: icloud)
            } else {
                let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
                let docDir: URL = homeDir.appendingPathComponent("Documents")
                testNotesDocument2(rootUrl: docDir)
            }
            print("**** ROOT \(NotesExportDocument.icloudRoot)")
            guard icloudRoot != nil else { fatalError("No ICloud Root") }

        })
    }

    static func testNotesDocument2(rootUrl: URL) {
        let url = rootUrl.appendingPathComponent("NotesText.txt")
        let notes = NotesExportDocument(fileURL: url)
        notes.save(to: url, for: .forCreating, completionHandler: { (Bool) in
            print("file is saved")
            notes.open(completionHandler: { (Bool) in
                print("file is opened")
                notes.picker(url: url)
            })
        })
    }
    
    //Override this method to load the document data into the app’s data model.
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        let data: Data = contents as! Data
        let msg = String(data: data, encoding: .utf8)
        print("message: \(msg)")
    }
    
    //Override this method to return the document data to be saved.
    override func contents(forType typeName: String) throws -> Any {
        let content = "Hello World"
        let data = content.data(using: .utf8)
        return data!
    }
    
    func picker(url: URL) {
        // public.item
        //let docPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        let docPicker = UIDocumentPickerViewController(url: url, in: .exportToService)
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
        print("Picker did Pick called \(urls)")
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Picker Cancelled is called")
    }
}
