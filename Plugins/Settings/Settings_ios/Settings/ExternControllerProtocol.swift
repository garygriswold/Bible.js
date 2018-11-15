//
//  ExternControllerProtocol.swift
//  Settings
//
//  Created by Gary Griswold on 10/7/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

protocol ExternControllerProtocol {
    
    func present(title: String)
}

class ExternControllerImpl : AppViewController, ExternControllerProtocol {

    private var textView: UITextView!
    private var navTitle: String?
    
    func present(title: String) {
        self.navTitle = title
    }
    
    override func loadView() {
        super.loadView()
        
        // set Top Bar items
        self.navigationItem.title = self.navTitle
        
        self.textView = UITextView(frame: self.view.bounds)
        let inset = self.textView.frame.width * 0.05
        self.textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.textView.text = "To Be Developed"
        self.textView.isEditable = false
        self.textView.isSelectable = false
        self.textView.font = AppFont.serif(style: .body)
        self.view.addSubview(self.textView)
    }
}
