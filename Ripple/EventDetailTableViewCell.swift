//
//  EventDetailTableViewCell.swift
//  Ripple
//
//  Created by evgeny on 29.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class EventDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameDetailLabel: UILabel!
    @IBOutlet weak var layoutWidthAccessory: NSLayoutConstraint!
    
    let widthAccessory: CGFloat = 8
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func needShowAccessory(needed: Bool) {
        layoutWidthAccessory.constant = needed ? widthAccessory : 0
        layoutIfNeeded()
    }
}
