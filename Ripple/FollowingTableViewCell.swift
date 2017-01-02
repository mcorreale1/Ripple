//
//  FollowingTableViewCell.swift
//  Ripple
//
//  Created by evgeny on 26.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class FollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var accessoryCell: UIImageView!
    static let kCellHeight: CGFloat = 76.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutIfNeeded()
        pictureImageView.layer.cornerRadius = pictureImageView.frame.width / 2
        pictureImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
