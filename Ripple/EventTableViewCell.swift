//
//  EventTableViewCell.swift
//  Ripple
//
//  Created by evgeny on 26.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventPictureImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventOrganizationNameLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    static let kCellHeight: CGFloat = 115
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutIfNeeded()
        eventPictureImageView.layer.cornerRadius = eventPictureImageView.frame.width / 2
        eventPictureImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
