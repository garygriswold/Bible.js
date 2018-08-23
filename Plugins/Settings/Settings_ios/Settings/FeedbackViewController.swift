//
//  FeedbackViewController.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

//import Foundation
import UIKit
import AWS

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    private var textView: UITextView!
    
    deinit {
        print("**** deinit FeedbackViewController ******")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // set Top Bar items
        self.navigationItem.title = "Send Us Feedback"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                                                                action: #selector(cancelHandler))
        
        self.textView = UITextView(frame: UIScreen.main.bounds)
        let inset = self.textView.frame.width * 0.05
        self.textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.textView.isEditable = true
        self.textView.isSelectable = true
        self.textView.allowsEditingTextAttributes = true
        self.textView.font = AppFont.sansSerif(style: .body)
        self.view.addSubview(self.textView)
        
        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(preferredContentSizeChanged(note:)),
                           name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.textView.becomeFirstResponder()
    }
    
    //func textViewDidEndEditing(_ textView: UITextView) {
    //    print(textView.text)
    //}
    
    @objc func preferredContentSizeChanged(note: NSNotification) {
        self.textView.font = AppFont.sansSerif(style: .body)
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if let keyboardInfo: Dictionary = note.userInfo {
            if let keyboardRect: CGRect = keyboardInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = keyboardRect.minY
                let bounds = UIScreen.main.bounds
                textView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: keyboardTop)
            }
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
        self.textView.frame = UIScreen.main.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let adapter = SettingsAdapter()
        let userId: String = adapter.getPseudoUserId()
        if let text: String = self.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if !text.isEmpty {
                let aws = AwsS3Manager.findUSEast1()
                let key = userId + String(text.hashValue)
                let message = userId + "|" + text
                aws.uploadText(s3Bucket: "user.feedback.safebible", s3Key: key, data: message,
                               contentType: "text/plain; charset=UTF-8",
                           complete: { error in
                            if let err = error {
                                print("ERROR in upload of user feedback \(err)")
                            }
                })
            }
        }
        print("Feedbck view Will Disappear")
    }
    
    @objc func cancelHandler(sender: UIBarButtonItem?) {
        print("Feedback Cancel bar clicked")
        self.navigationController?.popViewController(animated: true)
    }
}
