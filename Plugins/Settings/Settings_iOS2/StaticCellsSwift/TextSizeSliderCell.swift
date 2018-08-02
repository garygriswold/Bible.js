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
    
    let controller: SettingsViewController
    let textSlider: UISlider
    let leftLabel: UILabel
    let rightLabel: UILabel
    
    init(controller: SettingsViewController, style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.controller = controller
        self.textSlider = UISlider(frame: .zero)
        self.leftLabel = UILabel(frame: .zero)
        self.rightLabel = UILabel(frame: .zero)
        self.textSlider.value = Float(AppFont.userFontDelta)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        self.controller = SettingsViewController(settingsViewType: .primary)
        self.textSlider = UISlider(frame: CGRect.zero)
        self.leftLabel = UILabel(frame: .zero)
        self.rightLabel = UILabel(frame: .zero)
        self.textSlider.value = Float(AppFont.userFontDelta)
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        
        self.textSlider.frame = CGRect(x: width * 0.1, y: 0, width: width * 0.75, height: height)
        self.textSlider.minimumValue = 0.75
        self.textSlider.maximumValue = 1.5
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
        AppFont.userFontDelta = CGFloat(sender.value)
        self.controller.tableView.reloadData()
        SearchCell.updateFontSize()
    }
}
