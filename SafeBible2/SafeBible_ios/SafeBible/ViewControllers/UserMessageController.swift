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
    
    static func present(controller: UIViewController?) {
        let userMessageController = UserMessageController()
        controller?.navigationController?.present(userMessageController, animated: true, completion: nil)
    }
    
    override func loadView() {
        super.loadView()
        
        self.modalTransitionStyle = .flipHorizontal
        self.messageComposeDelegate = self
        let message = NSLocalizedString("I like it!", comment: "User text in message to other")
        self.body = message + "\nhttps://itunes.apple.com/app/id1073396349"
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

