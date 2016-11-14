//
//  ProfilePictureImageView.swift
//  Ripple
//
//  Created by evgeny on 26.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class ProfilePictureImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
        backgroundColor = UIColor.whiteColor()
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
        clipsToBounds = true
    }
}
