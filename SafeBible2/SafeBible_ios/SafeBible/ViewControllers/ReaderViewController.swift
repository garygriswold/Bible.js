//
//  ReaderViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/16/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ReaderViewController : AppViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    private var _reference: Reference!
    var reference: Reference! {
        get { return _reference }
    }

    deinit {
        print("****** deinit Reader View Controller \(self._reference.toString())")
    }
    
    override func loadView() {
        super.loadView()
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        let js = Note.decodeRange + Note.installEffect + Note.encodeRange
        let script = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        let contentController = WKUserContentController()
        contentController.addUserScript(script)
        contentController.add(self, name: "book")
        contentController.add(self, name: "note")
        configuration.userContentController = contentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        self.webView.backgroundColor = AppFont.backgroundColor
        
        self.webView.scrollView.frame = self.view.bounds
        self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.backgroundColor = AppFont.backgroundColor
        
        self.view.addSubview(self.webView)
        
        self.webView.navigationDelegate = self
        
        self.webView.createEditMenu() // Found in extension WKWebView
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.webView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.webView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    func loadReference(reference: Reference) {
        self._reference = reference
        self.loadViewIfNeeded()
        let biblePage = BiblePageModel()
        biblePage.loadPage(reference: _reference, webView: self.webView)
    }
 
    func clearWebView() {
        if self.webView != nil {
            // measures about 0.35 to 0.7 ms on simulator
            self.webView.loadHTMLString(DynamicCSS.shared.getEmptyHtml(), baseURL: nil)
        }
    }
    
    @objc override func preferredContentSizeChanged(note: NSNotification) {
        super.preferredContentSizeChanged(note: note)

        let message = DynamicCSS.shared.fontSize.genRule()
        self.execJavascript(message: message)
    }

    func execJavascript(message: String) {
        self.webView.evaluateJavaScript(message, completionHandler: { data, error in
            if let err = error {
                print("jsCallbackError \(err)")
            }
            if let resp = data {
                print("jsCallback has a response \(resp)")
            }
        })
    }

    //
    // Delegate
    //
    func webView(_: WKWebView, didFinish: WKNavigation!) {
        print("Web page loaded \(_reference.toString())")
        self.webView.addNotes(reference: _reference)
        NotificationCenter.default.post(name: ReaderPagesController.WEB_LOAD_DONE, object: nil)
    }
    
    func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) {
        print("ERROR: Bible page load error \(withError)")
        NotificationCenter.default.post(name: ReaderPagesController.WEB_LOAD_DONE, object: nil)
    }
    
    //
    // WKScriptMessageHandler
    //
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let noteId = message.body as? String {
            if let note = NotesDB.shared.getNote(noteId: noteId) {
                if message.name == "book" {
                    self.bookmarkAlert(note: note)
                }
                else if message.name == "note" {
                    NoteEditViewController.present(note: note, webView: self.webView)
                }
            }
        }
    }
    
    private func bookmarkAlert(note: Note) {
        let reference = note.getReference()
        let passage = reference.description(startVerse: note.startVerse, endVerse: note.endVerse)
        let alert = UIAlertController(title: passage, message: "Bookmark", preferredStyle: .alert)
        let okString = NSLocalizedString("OK", comment: "Default action in Alert")
        let ok = UIAlertAction(title: okString, style: .default, handler: nil)
        alert.addAction(ok)
        let deleteString = NSLocalizedString("Delete", comment: "Delete bookmark action in Alert")
        let delete = UIAlertAction(title: deleteString, style: .destructive, handler: { _ in
            let message = "var ele = document.getElementById('\(note.noteId)');\n"
                + "var forget = ele.parentNode.removeChild(ele);\n"
            self.webView.evaluateJavaScript(message, completionHandler: { data, error in
                if let err = error {
                    print("ERROR: bookmarkAlert delete \(err)")
                }
            })
        })
        alert.addAction(delete)
        alert.preferredAction = ok
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController!.present(alert, animated: true, completion: nil)
    }
}
