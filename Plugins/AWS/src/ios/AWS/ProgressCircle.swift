//
//  ProgressCircle.swift
//  AWS
//
//  Created by Gary Griswold on 4/7/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation

public class ProgressCircle : UIView {

    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 20.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        progress = 0.0
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor.red.cgColor
        layer.addSublayer(circlePathLayer)
        backgroundColor = .white
    }
    
    func addToParentAndCenter(view: UIView) {
        view.addSubview(self)
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[v]|", options: .init(rawValue: 0),
            metrics: nil, views: ["v": self]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[v]|", options: .init(rawValue: 0),
            metrics: nil, views:  ["v": self]))
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
            } else if newValue < 0 {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        let circlePathBounds = circlePathLayer.bounds
        circleFrame.origin.x = circlePathBounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathBounds.midY - circleFrame.midY
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
}
