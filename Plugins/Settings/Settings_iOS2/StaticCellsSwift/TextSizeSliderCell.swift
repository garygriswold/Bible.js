//
//  TextSizeSliderCell.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 7/31/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

class TextSizeSliderCell : UITableViewCell {
    
    private static let indexPath = IndexPath(item: 0, section: 2) // Used by get cell location in table.
    private let controller: SettingsViewController
    private let textSlider: UISlider
    private let leftLabel: UILabel
    private let rightLabel: UILabel
    private var sampleTextLabel: UILabel?
    private var serifBodyFont: UIFont?
    
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
        
        self.textSlider.addTarget(self, action: #selector(touchDownHandler), for: .touchDown)
        self.textSlider.addTarget(self, action: #selector(valueChangedHandler), for: .valueChanged)
        self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpInside)
        self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpOutside)

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

    @objc func touchDownHandler(sender: UISlider) {
        let rect = self.controller.tableView.rectForRow(at: TextSizeSliderCell.indexPath)
        let width = rect.width
        let labelRect = CGRect(x: width * 0.05, y: (rect.minY - 35), width: (width * 0.9), height: 100)
        let label = UILabel(frame: labelRect)
        //label.drawText(in: CGRect(x: 50, y: 5, width: (width * 0.9) - 100, height: 90)) // could be in subclass
        label.text = "Your word is a lamp to my feet and a light to my path."
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.backgroundColor = UIColor.groupTableViewBackground
        label.alpha = 0.9
        //let textSize = label.intrinsicContentSize // could be useful to animate size of box
        self.sampleTextLabel = label
        self.serifBodyFont = AppFont.serif(ofRelativeSize: 1.0)
        self.valueChangedHandler(sender: sender) // set initial size correctly
        self.controller.tableView.addSubview(label)
    }

    @objc func valueChangedHandler(sender: UISlider) {
        if self.serifBodyFont != nil {
            sampleTextLabel?.font = self.serifBodyFont?.withSize(self.serifBodyFont!.pointSize * CGFloat(sender.value))
        }
    }
    
    @objc func touchUpHandler(sender: UISlider) {
        print("touch up \(sender.value)")
        AppFont.userFontDelta = CGFloat(sender.value)
        self.controller.tableView.reloadData()
        //SearchCell.updateFontSize()
        
        self.sampleTextLabel?.removeFromSuperview()
    }
}
