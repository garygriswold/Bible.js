//
//  AppFont.swift
//  Settings
//
//  Created by Gary Griswold on 8/1/18.
//  Copyright © 2018 Short Sands, LLC. All rights reserved.
//

import UIKit

public class AppFont {

    public static var serifFont: UIFont?
    public static let cellLabelFont = AppFont.sansSerif(style: .subheadline) // .callout is 20% larger
    public static let cellDetailFont = AppFont.sansSerif(style: .footnote)
    private static var _userFontDelta: CGFloat?
    private static var _bodyLineHeight: Float?
    private static var _nightMode: Bool?
    private static var _verseNumbers: Bool?
    
    public static var userFontDelta: CGFloat {
        get {
            if _userFontDelta == nil {
                let adapter = SettingsAdapter()
                _userFontDelta = adapter.getUserFontDelta()
            }
            return _userFontDelta!
        }
        set(newValue) {
            _userFontDelta = newValue
            let adapter = SettingsAdapter()
            adapter.setUserFontDelta(fontDelta: newValue)
        }
    }
    
    static var bodyLineHeight: Float {
        get {
            if _bodyLineHeight == nil {
                _bodyLineHeight = SettingsDB.shared.getFloat(name: "body-line-height", ifNone: 1.8)
            }
            return _bodyLineHeight!
        }
        set(newValue) {
            _bodyLineHeight = newValue
            SettingsDB.shared.updateFloat(name: "body-line-height", setting: newValue)
        }
    }
    
    static var nightMode: Bool {
        get {
            if _nightMode == nil {
                _nightMode = SettingsDB.shared.getBool(name: "night-mode", ifNone: false)
            }
            return _nightMode!
        }
        set(newValue) {
            _nightMode = newValue
            SettingsDB.shared.updateBool(name: "night-mode", setting: newValue)
        }
    }
    
    static var backgroundColor: UIColor {
        get { return nightMode ? .black : .white }
        //get { return .red }
    }
    
    static var groupTableViewBackground: UIColor {
        get { return UIColor.groupTableViewBackground }
    }
    
    static var textColor: UIColor {
        get { return nightMode ? .white : .black }
        //get { return .black }
    }
    
    static var verseNumbers: Bool {
        get {
            if _verseNumbers == nil {
                _verseNumbers = SettingsDB.shared.getBool(name: "verse-numbers", ifNone: true)
            }
            return _verseNumbers!
        }
        set(newValue) {
            _verseNumbers = newValue
            SettingsDB.shared.updateBool(name: "verse-numbers", setting: newValue)
        }
    }

    public static func sansSerif(style: UIFont.TextStyle) -> UIFont {
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
    
    public static func serif(style: UIFont.TextStyle) -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: style)
        return getSerifFont().withSize(font.pointSize * userFontDelta)
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
    
    // This does not appear to work. It must be that NavigationBar is overridding this setting.
    public static func updateSearchFontSize() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = AppFont.sansSerif(style: .body)
    }
    
    private static func getSerifFont() -> UIFont {
        if serifFont == nil {
            serifFont = UIFont(name: "Cambria", size: 16.0)
            if serifFont == nil {
                serifFont = UIFont(name: "Times", size: 16.0)
                if serifFont == nil {
                    serifFont = UIFont(name: "Cochin", size: 16.0)
                    if serifFont == nil {
                        serifFont = UIFont.systemFont(ofSize: 16.0)
                    }
                }
            }
        }
        return serifFont!
    }
}
