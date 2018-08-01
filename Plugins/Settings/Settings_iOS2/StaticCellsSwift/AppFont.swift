//
//  AppFont.swift
//  StaticCellsSwift
//
//  Created by Gary Griswold on 8/1/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import Foundation
import UIKit

public class AppFont {
    
    public static var userFontDelta: CGFloat = 1.0
    public static var serifFont: UIFont?
    
    public static func sansSerif(style: UIFontTextStyle) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        return font.withSize(font.pointSize * userFontDelta)
    }
    
    public static func sansSerif(ofSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize * userFontDelta)
    }
    
    public static func sansSerif(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize * userFontDelta, weight: weight)
    }
    
    public static func boldSansSerif(ofSize: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: ofSize * userFontDelta)
    }
    
    public static func italicSansSerif(ofSize: CGFloat) -> UIFont {
        return UIFont.italicSystemFont(ofSize: ofSize * userFontDelta)
    }
    
    public static func monospaced(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        return UIFont.monospacedDigitSystemFont(ofSize: ofSize * userFontDelta, weight: weight)
    }
    
    public static func serif(ofSize: CGFloat) -> UIFont {
        return getSerifFont().withSize(ofSize * userFontDelta)
    }
    
    public static func serif(ofActualSize: CGFloat) -> UIFont {
        return getSerifFont().withSize(ofActualSize)
    }
    
    public static func serif(ofRelativeSize: CGFloat) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: .body)
        return getSerifFont().withSize(font.pointSize * ofRelativeSize)
    }
    
    private static func getSerifFont() -> UIFont {
        if serifFont == nil {
            serifFont = UIFont(name: "Cochin", size: 50.0)
            if serifFont == nil {
                serifFont = UIFont(name: "Baskerville", size: 50.0)
                if serifFont == nil {
                    serifFont = UIFont(name: "Didot", size: 50.0)
                    if serifFont == nil {
                        serifFont = UIFont.systemFont(ofSize: 50.0)
                    }
                }
            }
        }
        return serifFont!
    }
}
