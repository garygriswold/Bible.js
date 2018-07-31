//
//  VersionSelectedCell.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/24/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class VersionCell : UITableViewCell {
    
    //var versionCode: String? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // UIFontTextStyle .largerTitle, .title1, .title2, .title3, .headline, .body, .callout
        // .subheadline, .footnote, .caption1, .caption2
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        
        self.accessoryType = UITableViewCellAccessoryType.detailButton // only works when not editing
    }
}
