//
//  TextHeightSliderCell.swift
//  Settings
//
//  Created by Gary Griswold on 11/3/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation
import UIKit

class TextHeightSliderCell : UITableViewCell {
    
    private static let indexPath = IndexPath(item: 1, section: 2) // Used by get cell location in table.
    private weak var tableView: UITableView?
    private let textSlider: UISlider
    private var sampleTextLabel: UILabel?
    private var pointSize: CGFloat?
    
    init(controller: SettingsViewController, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.tableView = controller.tableView
        self.textSlider = UISlider(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        self.textSlider = UISlider(frame: CGRect.zero)
        super.init(coder: coder)
    }
    
    deinit {
        print("**** deinit TextHeightSliderCell ******")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        
        self.backgroundColor = AppFont.backgroundColor
        
        var image = UIImage(named: "www/images/typ-height.png")
        image = image?.withRenderingMode(.alwaysTemplate)
        self.imageView!.tintColor = UIColor.gray
        self.imageView!.image = image
        
        self.textLabel?.text = "" // Required for image to appear
        
        let sliderX = self.textLabel!.frame.minX
        let sliderWid = (width * 0.90) - sliderX

        self.textSlider.frame = CGRect(x: sliderX, y: 0, width: sliderWid, height: height)
        
        self.textSlider.minimumValue = 1.2
        self.textSlider.maximumValue = 2.0
        self.textSlider.value = AppFont.bodyLineHeight
        self.textSlider.isContinuous = true
        
        self.textSlider.addTarget(self, action: #selector(touchDownHandler), for: .touchDown)
        
        self.addSubview(self.textSlider)
    }
    
    @objc func touchDownHandler(sender: UISlider) {
        if let rect = self.tableView?.rectForRow(at: TextHeightSliderCell.indexPath) {
            let width = rect.width
            // I don't know why -180 is correct.  It seems like is should be - 100
            let labelRect = CGRect(x: width * 0.05, y: (rect.minY - 360), width: (width * 0.9), height: 200)
            let label = UILabel(frame: labelRect)
            //label.drawText(in: CGRect(x: 50, y: 5, width: (width * 0.9) - 100, height: 90)) // could be in subclass
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 20
            label.layer.masksToBounds = true
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.backgroundColor = AppFont.groupTableViewBackground
            label.textColor = AppFont.textColor
            label.alpha = 0.9
            //let textSize = label.intrinsicContentSize // could be useful to animate size of box
            self.sampleTextLabel = label

            self.pointSize = AppFont.serif(style: .body).pointSize
            self.valueChangedHandler(sender: sender) // set initial size correctly
            self.tableView?.addSubview(label)
            
            self.textSlider.addTarget(self, action: #selector(valueChangedHandler), for: .valueChanged)
            self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpInside)
            self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpOutside)
        }
    }
    
    @objc func valueChangedHandler(sender: UISlider) {
        let html = "<html><body><p style='font-size:\(self.pointSize!)pt;" +
            " line-height:\(sender.value);" +
            " color:\(AppFont.textColorHEX);'>" +
            "Your word is a lamp to my feet and a light to my path." +
            "</p></body></html>"
        let data: Data? = html.data(using: .utf8)
        do {
            let attributed = try NSAttributedString(data: data!, documentAttributes: nil)
            self.sampleTextLabel?.attributedText = attributed
        } catch let err {
            print(err)
        }
    }
    
    @objc func touchUpHandler(sender: UISlider) {
        print("touch up \(sender.value)")
        AppFont.bodyLineHeight = sender.value
        self.sampleTextLabel?.removeFromSuperview()
    }
}

