//
//  SampleTextViewController.swift
//  Settings
//
//  Created by Gary Griswold on 11/14/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class SampleTextViewController : UIAlertController {//UIViewController {
    
    private var sampleLabel: UILabel!
    
    //override func loadView() {
    //    super.loadView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = UIScreen.main.bounds.width /// This needs to be replaced with something else, like view
        //let width = rect.width
        // I don't know why -180 is correct.  It seems like is should be - 100
        let labelRect = CGRect(x: width * 0.05, y: (300), width: (width * 0.9), height: 200)
        let label = UILabel(frame: labelRect)
        //label.drawText(in: CGRect(x: 50, y: 5, width: (width * 0.9) - 100, height: 90)) // could be in subclass
        label.text = "Your word is a lamp to my feet and a light to my path."
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
        self.sampleLabel = label
        self.view = label
        
        //self.pointSize = AppFont.serif(style: .body).pointSize
        //self.valueChangedHandler(sender: sender) // set initial size correctly
        //self.tableView?.addSubview(label)
        
        //self.textSlider.addTarget(self, action: #selector(valueChangedHandler), for: .valueChanged)
        //self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpInside)
        //self.textSlider.addTarget(self, action: #selector(touchUpHandler), for: .touchUpOutside)
    }
}
