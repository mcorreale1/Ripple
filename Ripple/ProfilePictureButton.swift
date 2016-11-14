//
//  ProfilePictureButton.swift
//  Ripple
//
//  Created by Nikita Egoshin on 9/23/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class ProfilePictureButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
        backgroundColor = UIColor.whiteColor()
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
        clipsToBounds = true
    }
}
