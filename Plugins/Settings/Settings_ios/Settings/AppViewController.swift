//
//  AppViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/25/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class AppViewController : UIViewController {
    
    override func loadView() {
        super.loadView()
       
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferredContentSizeChanged(note:)),
                           name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    /**
     * iOS 10 includes: .adjustsFontForContentSizeCategory, which can be set to each label to
     * perform automatic text size adjustment
     */
    @objc func preferredContentSizeChanged(note: NSNotification) {
        AppFont.userFontDelta = 1.0 // Reset App Text Slider to middle
        AppFont.updateSearchFontSize()
    }
}
