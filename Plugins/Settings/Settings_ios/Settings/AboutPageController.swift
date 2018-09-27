//
//  AboutPageController.swift
//  Settings
//
//  Created by Gary Griswold on 9/27/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class AboutPageController : UIViewController {
    
    private var textView: UITextView!
    
    init() {
        self.textView = UITextView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.textView = UITextView(frame: .zero)
        super.init(coder: coder)
    }
    
    deinit {
        print("**** deinit AboutPageController ******")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // set Top Bar items
        self.navigationItem.title = NSLocalizedString("About SafeBible", comment: "Title of Page")
        
        self.textView = UITextView(frame: UIScreen.main.bounds)
        let inset = self.textView.frame.width * 0.05
        self.textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.textView.text = aboutInfo()
        self.textView.isEditable = false
        self.textView.isSelectable = true
        self.textView.font = AppFont.serif(style: .body)
        self.view.addSubview(self.textView)
        
        // Wouldn't it also work to simply have the font set when viewDidAppear
        //let notify = NotificationCenter.default
        //notify.addObserver(self, selector: #selector(preferredContentSizeChanged(note:)),
        //                   name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        //
        //self.textView.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textView.font = AppFont.serif(style: .body)
    }
    
    //@objc func preferredContentSizeChanged(note: NSNotification) {
    //    self.textView.font = AppFont.sansSerif(style: .body)
    //}
    
    private func aboutInfo() -> String {
        let what = "Published by Short Sands, LLC\nVersion " + getAppVersion()
        return what
    }
    
    private func getAppVersion() -> String {
        let info = Bundle.main.infoDictionary
        return info?["CFBundleShortVersionString"] as? String ?? ""
    }
}
