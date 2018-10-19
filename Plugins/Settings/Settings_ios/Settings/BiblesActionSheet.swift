//
//  BiblesActionSheet.swift
//  Settings
//
//  Created by Gary Griswold on 10/19/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class BiblesActionSheet : UIAlertController {
    
    override var preferredStyle: UIAlertControllerStyle { get { return .actionSheet } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bible1 = UIAlertAction(title: "Bible1", style: .default, handler: { _ in
            print("Bible1 touched")
        })
        self.addAction(bible1)
        
        let bible2 = UIAlertAction(title: "Bible2", style: .default, handler: { _ in
            print("Bible2 touched")
        })
        self.addAction(bible2)
        //self.addAction(nil)
        
        let moreBiblesText = NSLocalizedString("+ More Bibles", comment: "Title on action sheet")
        let moreBibles = UIAlertAction(title: moreBiblesText, style: .default, handler: { _ in
            print("More Bible touched")
        })
        self.addAction(moreBibles)
        
        let moreLangText = NSLocalizedString("+ More Languages", comment: "Title on action sheet")
        let moreLang = UIAlertAction(title: moreLangText, style: .default, handler: { _ in
            print("More Languages touched")
        })
        self.addAction(moreLang)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("Cancel touched")
        })
        self.addAction(cancel)
    }
}
