//
//  FileCell.swift
//  Settings
//
//  Created by Gary Griswold on 12/31/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class FileCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("FileCell(coder:) is not implemented.")
    }
}
