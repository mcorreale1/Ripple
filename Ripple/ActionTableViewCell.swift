//
//  ActionTableViewCell.swift
//  Ripple
//
//  Created by evgeny on 28.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class ActionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
     static let kCellHeight: CGFloat = 51
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
