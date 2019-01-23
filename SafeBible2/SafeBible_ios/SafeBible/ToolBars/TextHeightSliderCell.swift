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
    
    private static var sampleTextLabel = UILabel()  // This is the sample text popup
    private static var sampleText = UILabel()       // This is only a holder of sample text
    
    private weak var tableView: UITableView?
    private let textSlider: UISlider
    private var pointSize: CGFloat?
    
    init(controller: MenuViewController, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.tableView = controller.tableView
        self.textSlider = UISlider(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("TextHeightSliderCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit TextHeightSliderCell ******")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        self.backgroundColor = AppFont.backgroundColor
        
        var image = UIImage(named: "www/images/typ-height.png")
        image = image?.withRenderingMode(.alwaysTemplate)
        self.imageView!.tintColor = UIColor.gray
        self.imageView!.image = image
        
        self.textLabel?.text = "" // Required for image to appear
        
        let sliderX = self.textLabel!.frame.minX
        let sliderWid = (bounds.width * 0.90) - sliderX

        self.textSlider.frame = CGRect(x: sliderX, y: 0, width: sliderWid, height: bounds.height)
        
        self.textSlider.minimumValue = 1.2
        self.textSlider.maximumValue = 2.0
        self.textSlider.value = AppFont.bodyLineHeight
        self.textSlider.isContinuous = true
        
        self.textSlider.addTarget(self, action: #selector(touchDownHandler), for: .touchDown)
        
        self.addSubview(self.textSlider)
    }
    
    @objc func touchDownHandler(sender: UISlider) {
        if TextHeightSliderCell.sampleTextLabel.text == nil {
            TextHeightSliderCell.sampleText.text = "Your word is a lamp to my feet and a light to my path."
            let label = UILabel()
            let current = HistoryModel.shared.current()
            let reference = Reference(bibleId: current.bibleId, bookId: "PSA", chapter: 119)
            let pageLoader = BiblePageModel()
            pageLoader.loadLabel(reference: reference, verse: 105, label: TextHeightSliderCell.sampleText)
            label.layer.borderWidth = 0.5
            label.layer.borderColor = UIColor.gray.cgColor
            label.layer.cornerRadius = 20
            label.layer.masksToBounds = true
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.alpha = 0.9
            TextHeightSliderCell.sampleTextLabel = label
        }

        self.pointSize = AppFont.serif(style: .body).pointSize
        self.valueChangedHandler(sender: sender) // set initial size correctly
        
        let versePopup = TextHeightSliderCell.sampleTextLabel
        versePopup.textColor = AppFont.textColor
        versePopup.backgroundColor = AppFont.groupTableViewBackground
        self.tableView?.addSubview(versePopup)
        
        versePopup.translatesAutoresizingMaskIntoConstraints = false
        
        let horzMargin = self.frame.width * 0.05
        versePopup.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: horzMargin).isActive = true
        versePopup.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horzMargin).isActive = true
        versePopup.bottomAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        self.textSlider.addTarget(self, action: #selector(valueChangedHandler), for: .valueChanged)
        self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpInside)
        self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpOutside)
    }
    
    @objc func valueChangedHandler(sender: UISlider) {
        let html = "<html><body><p style='font-size:\(self.pointSize!)pt;" +
            " margin-top:-20pt; margin-bottom:-20pt; padding:0;" +
            " line-height:\(sender.value);" +
            " text-align:center;" +
            " color:\(AppFont.textColorHEX);'>" +
            "\(TextHeightSliderCell.sampleText.text!)" +
            "</p></body></html>"
        let data: Data? = html.data(using: .utf8)
        do {
            let attributed = try NSAttributedString(data: data!, documentAttributes: nil)
            TextHeightSliderCell.sampleTextLabel.attributedText = attributed
        } catch let err {
            print(err)
        }
    }
    
    @objc func touchUpHandler(sender: UISlider) {
        print("touch up \(sender.value)")
        AppFont.bodyLineHeight = sender.value
        ReaderViewQueue.shared.updateCSS(css: DynamicCSS.shared.lineHeight.genRule())
        TextHeightSliderCell.sampleTextLabel.removeFromSuperview()
    }
}

