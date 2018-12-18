//
//  NoteCell.swift
//  Settings
//
//  Created by Gary Griswold on 12/18/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class NoteCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("NoteCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit NoteCell ******")
    }
}

