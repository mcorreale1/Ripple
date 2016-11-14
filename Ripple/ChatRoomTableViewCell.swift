//
//  ChatRoomTableViewCell.swift
//  Ripple
//
//  Created by HeroinoOp on 05.10.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {

    @IBOutlet weak var indicateView: UIView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var updateTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutIfNeeded()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        indicateView.cornerRadius = indicateView.height / 2
        indicateView.layer.masksToBounds = true
        indicateView.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.height / 2
        profileImage.layer.masksToBounds = true
        profileImage.clipsToBounds = true
        profileImage.image = UIImage(named: "user_dafault_picture")
        lastMessageLabel.numberOfLines = 2

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
