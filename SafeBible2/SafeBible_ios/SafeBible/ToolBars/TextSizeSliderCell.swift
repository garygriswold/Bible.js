//
//  TextSizeSliderCell.swift
//  Settings
//
//  Created by Gary Griswold on 7/31/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

class TextSizeSliderCell : UITableViewCell {
    
    private static var sampleTextLabel = UILabel() // This is the sampleTextPopup
    private static var sampleText = UILabel()      // This is only a holder of the sample text
    
    private weak var tableView: UITableView?
    private let textSlider: UISlider
    private let leftLabel: UILabel
    private let rightLabel: UILabel
    private var serifBodyFont: UIFont?
    
    init(controller: MenuViewController, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.tableView = controller.tableView
        self.textSlider = UISlider(frame: .zero)
        self.leftLabel = UILabel(frame: .zero)
        self.rightLabel = UILabel(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("TextSizeSliderCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit TextSizeSliderCell ******")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let width = bounds.width
        let height = bounds.height
        
        self.backgroundColor = AppFont.backgroundColor
        
        if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight {
            self.textSlider.frame = CGRect(x: width * 0.1, y: 0, width: width * 0.75, height: height)
            self.leftLabel.frame = CGRect(x: width * 0.05, y: 0, width: width * 0.05, height: height)
            self.rightLabel.frame = CGRect(x: width * 0.88, y: 0, width: width * 0.10, height: height)
        } else {
            self.textSlider.frame = CGRect(x: width * 0.12, y: 0, width: width * 0.80, height: height)
            self.rightLabel.frame = CGRect(x: width * 0.01, y: 0, width: width * 0.10, height: height)
            self.leftLabel.frame = CGRect(x: width * 0.88, y: 0, width: width * 0.10, height: height)
        }

        self.textSlider.minimumValue = 0.75
        self.textSlider.maximumValue = 1.5
        self.textSlider.value = Float(AppFont.userFontDelta)
        self.textSlider.isContinuous = true
        
        self.textSlider.addTarget(self, action: #selector(touchDownHandler), for: .touchDown)

        self.addSubview(self.textSlider)
        
        let titleLetter = "A"
        self.leftLabel.text = titleLetter
        self.leftLabel.font = AppFont.serif(ofRelativeSize: CGFloat(self.textSlider.minimumValue))
        self.leftLabel.textColor = AppFont.textColor
        self.addSubview(self.leftLabel)
        
        self.rightLabel.text = titleLetter
        self.rightLabel.font = AppFont.serif(ofRelativeSize: CGFloat(self.textSlider.maximumValue))
        self.rightLabel.textColor = AppFont.textColor
        self.addSubview(self.rightLabel)
    }

    @objc func touchDownHandler(sender: UISlider) {
        if TextSizeSliderCell.sampleTextLabel.text == nil {
            TextSizeSliderCell.sampleText.text = "Your word is a lamp to my feet and a light to my path."
            let label = UILabel()
            let current = HistoryModel.shared.current()
            let reference = Reference(bibleId: current.bibleId, bookId: "PSA", chapter: 119)
            let pageLoader = BiblePageModel()
            pageLoader.loadLabel(reference: reference, verse: 105, label: TextSizeSliderCell.sampleText)
            label.layer.borderWidth = 0.5
            label.layer.borderColor = UIColor.gray.cgColor
            label.layer.cornerRadius = 20
            label.layer.masksToBounds = true
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.alpha = 0.9
            TextSizeSliderCell.sampleTextLabel = label
        }
        // can this line be static?
        self.serifBodyFont = AppFont.serif(ofRelativeSize: 1.0)
        self.valueChangedHandler(sender: sender) // set initial size correctly
        
        let versePopup = TextSizeSliderCell.sampleTextLabel
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
        let fontSize = self.serifBodyFont!.pointSize * CGFloat(sender.value)
        let html = "<html><body><p style='font-size:\(fontSize)pt;" +
            " margin-top:-20pt; margin-bottom:-20pt; padding:0;" +
            " line-height:\(AppFont.bodyLineHeight);" +
            " text-align:center;" +
            " color:\(AppFont.textColorHEX);'>" +
            "\(TextSizeSliderCell.sampleText.text!)" +
            //"Your word is a lamp to my feet and a light to my path." +
        "</p></body></html>"
        let data: Data? = html.data(using: .utf8)
        do {
            let attributed = try NSAttributedString(data: data!, documentAttributes: nil)
            TextSizeSliderCell.sampleTextLabel.attributedText = attributed
        } catch let err {
            print(err)
        }
    }
    
    @objc func touchUpHandler(sender: UISlider) {
        AppFont.userFontDelta = CGFloat(sender.value)
        self.tableView!.reloadData()
        AppFont.updateSearchFontSize()
        
        ReaderViewQueue.shared.updateCSS(css: DynamicCSS.shared.fontSize.genRule())
        
        TextSizeSliderCell.sampleTextLabel.removeFromSuperview()
    }
}
