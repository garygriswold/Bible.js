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
        
        self.modalTransitionStyle = .coverVertical
        self.messageComposeDelegate = self
        self.body = "\n\nhttps://itunes.apple.com/app/id1073396349"
        //self.body = "http://appstore.com/safebibleprivacysafebible"
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

