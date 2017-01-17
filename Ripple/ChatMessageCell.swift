//
//  ChatMessageCell.swift
//  Ripple
//
//  Created by Nikita Egoshin on 10/6/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {

    @IBOutlet weak var cloudView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var lyocLeftOffset: NSLayoutConstraint!
    @IBOutlet weak var lyocRightOffset: NSLayoutConstraint!
    
    var isOwnMessage: Bool = false {
        didSet {
            lyocLeftOffset.priority = isOwnMessage ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
            lyocRightOffset.priority = isOwnMessage ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
            self.layoutIfNeeded()
            cloudView.backgroundColor = isOwnMessage ? UIColor.darkGrayColor() : UIColor(red: 132.0/255.0, green: 41.0/255.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
