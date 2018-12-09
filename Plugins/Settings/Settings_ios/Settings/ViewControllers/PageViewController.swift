//
//  PageViewController.swift
//  Settings
//
//  Created by Gary Griswold on 11/19/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import UIKit

class PageViewController : UIPageViewController {
    
    private var pageControl: UIPageControl?
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("PageViewController(coder:) is not implemented.")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.pageControl = self.findPageControl(view: self.view)
        self.layoutPageControl()
    }
    
    private func findPageControl(view: UIView) -> UIPageControl? {
        for vue in view.subviews {
            if vue is UIPageControl {
                return (vue as! UIPageControl)
            }
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = AppFont.backgroundColor
        self.layoutPageControl()
    }
    
    private func layoutPageControl() {
        if let control = self.pageControl {
            control.backgroundColor = AppFont.backgroundColor
            control.pageIndicatorTintColor = .lightGray
            control.currentPageIndicatorTintColor = AppFont.nightMode ? .white : .black
            
            let layer = CALayer()
            layer.borderColor = UIColor.lightGray.cgColor
            layer.borderWidth = 0.3
            layer.frame = CGRect(x: 0, y: 0, width: control.frame.width, height: 0.3)
            control.layer.addSublayer(layer)
        }
    }
}
