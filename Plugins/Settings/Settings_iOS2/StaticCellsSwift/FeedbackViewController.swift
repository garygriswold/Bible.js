//
//  FeedbackViewController.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/30/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    //@IBOutlet
    var textView: UITextView!
    
    //var note: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = UIScreen.main.bounds
        let rect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height / 2)
        self.textView = UITextView(frame: rect)
        self.textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.view = self.textView
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(preferredContentSizeChanged(note:)),
                                               name: NSNotification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //note.contents = textView.text
        print(textView.text)
    }
    
    @objc func preferredContentSizeChanged(note: NSNotification) {
        self.textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        // tableView.reloadData() if it were a table.
    }
    
}
