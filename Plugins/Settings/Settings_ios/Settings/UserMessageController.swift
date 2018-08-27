//
//  UserMessageController.swift
//  Settings
//
//  Created by Gary Griswold on 8/27/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import MessageUI

class UserMessageController : MFMessageComposeViewController, MFMessageComposeViewControllerDelegate {
    
    static func isAvailable() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    override func loadView() {
        super.loadView()
        
        self.modalTransitionStyle = .flipHorizontal
        self.messageComposeDelegate = self
        self.body = "I like it!\nhttps://itunes.apple.com/app/id1073396349"
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

