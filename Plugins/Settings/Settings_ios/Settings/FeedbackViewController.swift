//
//  FeedbackViewController.swift
//  Settings
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//
import UIKit
import AWS
import AudioToolbox

class FeedbackViewController: AppViewController, UITextViewDelegate {
    
    private var textView: UITextView!
    
    deinit {
        print("**** deinit FeedbackViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        // set Top Bar items
        self.navigationItem.title = NSLocalizedString("Send Us Comments", comment: "Feedback view title")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self,
                                                                action: #selector(replyHandler))
        
        self.textView = UITextView(frame: self.view.bounds)
        self.textView.backgroundColor = AppFont.backgroundColor
        self.textView.textColor = AppFont.textColor
        let inset = self.textView.frame.width * 0.05
        self.textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.textView.isEditable = true
        self.textView.isSelectable = true
        self.textView.allowsEditingTextAttributes = true
        self.textView.font = AppFont.sansSerif(style: .body)
        self.view.addSubview(self.textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.font = AppFont.sansSerif(style: .body)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let notify = NotificationCenter.default
        notify.addObserver(self, selector: #selector(keyboardWillShow),
                           name: UIResponder.keyboardWillShowNotification, object: nil)
        notify.addObserver(self, selector: #selector(keyboardWillHide),
                           name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.textView.becomeFirstResponder()
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
    
    @objc func replyHandler(sender: UIBarButtonItem?) {
        self.uploadMessage()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func uploadMessage() {
        if let text: String = self.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if !text.isEmpty {
                self.playMessageSentSound()
                let adapter = SettingsAdapter()
                let userId: String = adapter.getPseudoUserId()
                let aws = AwsS3Manager.findUSEast1()
                let key = userId + String(text.hashValue)
                let message = userId + "\n" + Locale.current.identifier + "\n" + text
                aws.uploadText(s3Bucket: "user.feedback.safebible", s3Key: key, data: message,
                               contentType: "text/plain; charset=UTF-8",
                               complete: { error in
                                if let err = error {
                                    print("ERROR in upload of user feedback \(err)")
                                }
                })
            }
        }
    }
    
    private func playMessageSentSound() {
        var soundID: SystemSoundID = 0
        if let url = Bundle.main.url(forResource: "www/audio/Sent", withExtension: "aiff") {
            AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
