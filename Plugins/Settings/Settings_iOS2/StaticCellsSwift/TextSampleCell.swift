//
//  TextSampleCell.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/31/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit


//// This is not being used yet.
class TextSampleCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = self.textLabel?.frame
        print("size \(rect)")
        
        if let label = self.textLabel {
            label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.preferredMaxLayoutWidth = self.bounds.width
            let width = self.bounds.width
            let height = self.bounds.height
            //label.frame = CGRect(x: 20, y: 20, width: 250, height: 55)
            //label.drawText(in: rect)
            label.text = "Your word is a lamp to my feet and a light to my path." +
            " Your word is a lamp to my feet and a light to my path."
        }
    }
}
