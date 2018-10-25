//
//  AboutPageController.swift
//  Settings
//
//  Created by Gary Griswold on 9/27/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class InfoPageController : AppViewController {
    
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
        
        // set Top Bar items
        self.navigationItem.title = NSLocalizedString("Privacy Policy", comment: "Title of Page")
        
        self.textView = UITextView(frame: UIScreen.main.bounds)
        let inset = self.textView.frame.width * 0.05
        self.textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.textView.text = aboutInfo()
        self.textView.isEditable = false
        self.textView.isSelectable = true
        self.textView.font = AppFont.serif(style: .body)
        self.view.addSubview(self.textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textView.font = AppFont.serif(style: .body)
        
        let navHeight = self.navigationController?.navigationBar.frame.size.height ?? 44
        let point = CGPoint(x: 0, y: navHeight)
        self.textView.setContentOffset(point, animated: false)
    }
    
    private func aboutInfo() -> String {
        let message = "SafeBible - A free Bible App that protects your privacy.\n\n" +
            "Privacy Policy\n\n" +
            "The “SafeBible” App is designed to insure every reader’s anonymity." +
            "  It collects no information about any user, or about any user’s device," +
            " or any user’s location.  Nor, does it perform any transactions over the" +
            " Internet that can be blocked or monitored by a government opposed to Christianity." +
            " The App does not require the user to login or register any information," +
            " nor does the App use cookies or any other mechanism to track users of the App." +
            "  The App does not collect any information about its readers. For example," +
            " it does not collect device serial numbers, or other device identifiers," +
            " or Internet addresses. It does not collect user’s GPS location.\n\n" +
            "To best of our knowledge, “SafeBible” is the only Bible App, which provides" +
            " users with this degree of privacy.\n\n" +
            "Some governments, who are opposed to Christianity, attempt to block access to the Bible." +
            "  They are not able to block “SafeBible”.\n\n" +
            "“SafeBible” is free and does not advertise in the App.  And, it does not use" +
            " the App to sell other products or books.\n\n" +
            "Published by, Short Sands, LLC\n" +
            "Giving the world a free mobile Bible that is safe to use in any country.\n\n" +
            "Version "
        return message + getAppVersion()
    }
    
    private func getAppVersion() -> String {
        let info = Bundle.main.infoDictionary
        return info?["CFBundleShortVersionString"] as? String ?? ""
    }
}
