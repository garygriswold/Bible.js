//
//  UserMessageController.swift
//  Settings
//
//  Created by Gary Griswold on 8/27/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import MessageUI

class UserMessageController : UIViewController, MFMessageComposeViewControllerDelegate {
    
    static func isAvailable() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    //func presentCompose() {
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .white
        
        let composer = MFMessageComposeViewController()
        composer.modalTransitionStyle = .flipHorizontal
        composer.messageComposeDelegate = self
        composer.body = "Hello from California!"
        if let appURL = URL(string: "https://itunes.apple.com/app/id1073396349") {
            composer.addAttachmentURL(appURL, withAlternateFilename: nil)
        }
        
        self.present(composer, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

