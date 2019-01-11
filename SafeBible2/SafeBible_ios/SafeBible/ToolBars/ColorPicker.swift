//
//  ColorPicker.swift
//  Settings
//
//  Created by Gary Griswold on 11/20/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import WebKit

class ColorPicker : UIView {
    
    private static let yellow = UIColor(displayP3Red: 0.91015, green: 0.89843, blue: 0.39062, alpha: 1.0) // E9 E6 64
    private static let red =    UIColor(displayP3Red: 0.66015, green: 0.31640, blue: 0.57031, alpha: 1.0) // A9 51 92
    private static let orange = UIColor(displayP3Red: 0.77343, green: 0.48046, blue: 0.26171, alpha: 1.0) // C6 7B 43
    private static let green =  UIColor(displayP3Red: 0.51562, green: 0.69921, blue: 0.36718, alpha: 1.0) // 84 B3 5E
    private static let blue =   UIColor(displayP3Red: 0.48046, green: 0.67968, blue: 0.77734, alpha: 1.0) // 7B AE C7
    //private static let purple = UIColor(displayP3Red: 0.57031, green: 0.32421, blue: 0.58593, alpha: 1.0) // 92 53 96
    private static let salmon = UIColor(displayP3Red: 0.76953, green: 0.37890, blue: 0.42578, alpha: 1.0) // C5 61 6D
    private static let clear = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    static func toHEX(color: UIColor) -> String {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let red = Int(255.0 * r)
        let gre = Int(255.0 * g)
        let blu = Int(255.0 * b)
        let alf = Int(64.0 * a)
        return String(format: "#%02x%02x%02x%02x", red, gre, blu, alf)
    }
    
    private let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init(frame: .zero)
        self.frame = computeFrame()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.backgroundColor = AppFont.textColor
        self.alpha = 0.8
        
        let colors = [ColorPicker.yellow, ColorPicker.red, ColorPicker.orange, ColorPicker.green, ColorPicker.blue,
                      ColorPicker.salmon, ColorPicker.clear]
        let dotDiameter: CGFloat = 30.0
        let yPos = (frame.height - dotDiameter) / 2.0
        let spacer = (frame.width - (dotDiameter * CGFloat(colors.count))) / CGFloat(colors.count + 1)
        var xPos = spacer
        for color in colors {
            let frame = CGRect(x: xPos, y: yPos, width: dotDiameter, height: dotDiameter)
            let coloredDot = drawDot(frame: frame, color: color)
            self.addSubview(coloredDot)
            xPos += spacer + dotDiameter
        }
    }
    
    private func computeFrame() -> CGRect {
        let menu = UIMenuController.shared.menuFrame
        var yAdd: CGFloat = -menu.height
        switch UIMenuController.shared.arrowDirection {
        case .default:
            yAdd = -menu.height
        case .up:
            yAdd = menu.height
        case .down:
            yAdd = -menu.height
        case .left:
            yAdd = 0.0 // not tested
        case .right:
            yAdd = 0.0 // not tested
        }
        let result = CGRect(x: menu.minX, y: (menu.minY + yAdd), width: menu.width, height: menu.height)
        return result
    }
    
    private func drawDot(frame: CGRect, color: UIColor) -> UILabel {
        let label = UILabel(frame: frame)
        label.backgroundColor = color
        label.layer.cornerRadius = frame.width / 2.0
        label.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self.webView, action:  #selector(self.webView.colorTouchHandler))
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }
    
    required init(coder: NSCoder) {
        self.webView = WKWebView()
        //self.selection = Selection(selection: "startNode:1:2/endNode:1:2")
        super.init(coder: coder)!
    }
}
