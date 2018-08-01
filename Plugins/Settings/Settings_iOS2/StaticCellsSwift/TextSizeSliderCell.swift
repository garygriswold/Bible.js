//
//  TextSizeSliderCell.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/31/18.
//  Copyright © 2018 iOSExamples. All rights reserved.
//

import Foundation
import UIKit

class TextSizeSliderCell : UITableViewCell {
    
    let textSlider: UISlider
    let leftLabel: UILabel
    let rightLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.textSlider = UISlider(frame: .zero)
        self.leftLabel = UILabel(frame: .zero)
        self.rightLabel = UILabel(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        self.textSlider = UISlider(frame: CGRect.zero)
        self.leftLabel = UILabel(frame: .zero)
        self.rightLabel = UILabel(frame: .zero)
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        
        self.textSlider.frame = CGRect(x: width * 0.1, y: 0, width: width * 0.75, height: height)
        self.textSlider.minimumValue = 0.5
        self.textSlider.maximumValue = 2.0
        self.textSlider.isContinuous = true
        
        self.textSlider.addTarget(self, action: #selector(textSliderChanged), for: .valueChanged)
        self.textSlider.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.textSlider.addTarget(self, action: #selector(touchUp), for: .touchUpOutside)
        self.addSubview(self.textSlider)
        
        self.leftLabel.frame = CGRect(x: width * 0.05, y: 0, width: width * 0.05, height: height)
        self.leftLabel.text = "A"
        self.leftLabel.font = AppFont.serif(ofRelativeSize: CGFloat(self.textSlider.minimumValue))
        self.addSubview(self.leftLabel)
        
        self.rightLabel.frame = CGRect(x: width * 0.88, y: 0, width: width * 0.10, height: height)
        self.rightLabel.text = "A"
        self.rightLabel.font = AppFont.serif(ofRelativeSize: CGFloat(self.textSlider.maximumValue))
        self.addSubview(self.rightLabel)
    }
    
    @objc func textSliderChanged(sender: UISlider) {
        print("slider value \(sender.value)")
    }
    
    @objc func touchUp(sender: UISlider) {
        print("touch up \(sender.value)")
    }
}
