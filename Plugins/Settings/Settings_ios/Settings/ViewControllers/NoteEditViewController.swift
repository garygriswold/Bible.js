//
//  NoteViewController.swift
//  Settings
//
//  Created by Gary Griswold on 12/10/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import WebKit

class NoteEditViewController : AppViewController, UITextViewDelegate {
    
    static func present(note: Note, webView: WKWebView) {
        let notebook = NoteEditViewController(note: note, webView: webView)
        notebook.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        notebook.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navController = UINavigationController(rootViewController: notebook)
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController!.present(navController, animated: true, completion: nil)
    }
    
    private var note: Note
    private weak var webView: WKWebView?
    private var textView: UITextView!
    private var isModal: Bool
    
    init(note: Note, webView: WKWebView?) {
        self.note = note
        self.webView = webView
        self.isModal = (webView != nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NoteEditViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit NoteViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        let reference = note.getReference()
        let passage = reference.description(startVerse: note.startVerse, endVerse: note.endVerse)
        self.navigationItem.title = passage
        self.cancelHandler(sender: nil) // Set buttons to initial state
        
        self.textView = UITextView(frame: self.view.bounds)
        self.textView.backgroundColor = AppFont.backgroundColor
        self.textView.textColor = AppFont.textColor
        let inset = self.textView.frame.width * 0.05
        self.textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.textView.isEditable = false
        self.textView.isSelectable = false
        self.textView.allowsEditingTextAttributes = false
        self.textView.font = AppFont.sansSerif(style: .body)
        self.view.addSubview(self.textView)
        
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = view.safeAreaLayoutGuide
        self.textView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.textView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        self.textView.text = note.note
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardInfo: Dictionary = note.userInfo {
            if let keyboardRect: CGRect = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = keyboardRect.minY
                let bounds = self.view.bounds
                textView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: keyboardTop)
            }
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.textView.frame = self.view.bounds
    }
    
    @objc func doneHandler(sender: UIBarButtonItem) {
        if self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0 {
            let message = "var ele = document.getElementById('\(note.noteId)');\n"
                + "var forget = ele.parentNode.removeChild(ele);\n"
            if self.webView != nil {
                self.webView!.evaluateJavaScript(message, completionHandler: { data, error in
                    if let err = error {
                        print("ERROR: doneHandler note delete \(err)")
                    } else {
                        NotesDB.shared.deleteNote(noteId: self.note.noteId)
                    }
                })
            } else {
                NotesDB.shared.deleteNote(noteId: self.note.noteId)
            }
        }
        if self.isModal {
             self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    @objc func editHandler(sender: UIBarButtonItem) {
        self.textView.isEditable = true
        self.textView.isSelectable = true
        self.textView.allowsEditingTextAttributes = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                                                                action: #selector(cancelHandler))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                                                 action: #selector(saveHandler))
    }
    
    @objc func saveHandler(sender: UIBarButtonItem) {
        self.note.note = self.textView.text
        NotesDB.shared.storeNote(note: self.note)
        self.cancelHandler(sender: sender)
    }
    
    @objc func cancelHandler(sender: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                                                action: #selector(doneHandler))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self,
                                                                 action: #selector(editHandler))
    }
}
