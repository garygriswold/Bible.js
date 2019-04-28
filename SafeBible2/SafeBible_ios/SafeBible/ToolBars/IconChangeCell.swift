//
//  IconChangeCell.swift
//  SafeBible
//
//  Created by Gary Griswold on 4/26/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import UIKit

class IconChangeCell : UITableViewCell {
    
    private let icons: [String] = ["cross1", "book1"]
    private var iconControl: UISegmentedControl!
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("IconChangeCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit IconChangeCell ******")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = AppFont.backgroundColor
        
        var image = UIImage(named: "com-touchpad.png")!
        image = image.withRenderingMode(.alwaysTemplate)
        self.imageView!.tintColor = UIColor.gray
        self.imageView!.image = image
 /*
        self.textLabel?.text = NSLocalizedString("Icons", comment: "Home screen icon")
        self.textLabel?.sizeToFit()
        self.textLabel?.backgroundColor = .red
        //self.textLabel?.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        //self.textLabel?.numberOfLines = 1
        //let bounds = self.bounds
*/
        let images: [UIImage] = self.icons.map { self.getImage(iconName: $0 )}
        self.iconControl = UISegmentedControl(items: ["Bob", "Alice"])
      //  self.iconControl = UISegmentedControl(items: images)
        //self.iconControl = UISegmentedControl()
      //  self.iconControl.setImage(images[0], forSegmentAt: 0)
      //  self.iconControl.setImage(images[1], forSegmentAt: 1)

        self.addSubview(self.iconControl)
        self.iconControl.translatesAutoresizingMaskIntoConstraints = false
        let vue = self.contentView
        self.iconControl.topAnchor.constraint(equalTo: vue.topAnchor, constant: 7.0).isActive = true
        self.iconControl.leadingAnchor.constraint(equalTo: self.imageView!.trailingAnchor,
                                                  constant: 20).isActive = true
        self.iconControl.trailingAnchor.constraint(equalTo: vue.trailingAnchor,
                                                   constant: -20).isActive = true
        self.iconControl.bottomAnchor.constraint(equalTo: vue.bottomAnchor, constant: -7.0).isActive = true
        
        let iconName: String = UIApplication.shared.alternateIconName!
        self.iconControl.selectedSegmentIndex = self.icons.firstIndex(of: iconName)!
        self.iconControl.addTarget(self, action: #selector(changeIconHandler), for: .valueChanged)

    }
    
    @objc func changeIconHandler(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        print("selected \(index) \(sender.numberOfSegments)")
        let iconName = self.icons[index]
        /*
        if UIApplication.shared.supportsAlternateIcons {
            UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
                if let err = error {
                    print("ERROR: IconChangeCell \(err)")
                }
            })
        }*/
        self.reloadInputViews()
    }
    
    private func getImage(iconName: String) -> UIImage {
        //let bundle = Bundle.main
        
        //NSBundle* myBundle = [NSBundle mainBundle];
        //NSString* myImage = [myBundle pathForResource:@"Seagull" ofType:@"jpg"];
        
        //let path = "www/icons/\(iconName)-Small-40"//.png"
        //let path = "\(iconName)"
        //let image = UIImage(named: path)
        //let path2 = bundle.path(forResource: path, ofType: "png")!
        let image = UIImage(named: "www/icons/" +  iconName + "-Small.png")
        return image!
    }
}


