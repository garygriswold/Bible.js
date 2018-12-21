//
//  NoteCell.swift
//  Settings
//
//  Created by Gary Griswold on 12/18/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class NoteCell : UITableViewCell {
    
    let iconGlyph: UILabel
    let passage: UILabel
    let noteText: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.iconGlyph = UILabel()
        self.passage = UILabel()
        self.noteText = UILabel()
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.iconGlyph)
        self.contentView.addSubview(self.passage)
        self.contentView.addSubview(self.noteText)
        
        self.iconGlyph.translatesAutoresizingMaskIntoConstraints = false
        let margins = self.contentView.layoutMarginsGuide
        self.iconGlyph.topAnchor.constraint(equalTo: margins.topAnchor, constant: -3.0).isActive = true
        self.iconGlyph.leadingAnchor.constraint(equalTo: margins.leadingAnchor,
                                                constant: 0.0).isActive = true
        
        self.passage.translatesAutoresizingMaskIntoConstraints = false
        self.passage.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        self.passage.leadingAnchor.constraint(equalTo: self.iconGlyph.trailingAnchor,
                                              constant: 2.0).isActive = true
        
        self.noteText.translatesAutoresizingMaskIntoConstraints = false
        self.noteText.topAnchor.constraint(equalTo: iconGlyph.bottomAnchor, constant: 5.0).isActive = true
        self.noteText.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        self.noteText.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.noteText.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("NoteCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit NoteCell ******")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = AppFont.backgroundColor
    }
}

