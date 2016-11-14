//
//  OrganizationTableViewCell.swift
//  Ripple
//
//  Created by evgeny on 26.07.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

class OrganizationTableViewCell: UITableViewCell {

    @IBOutlet weak var organizationPictureImageView: UIImageView!
    @IBOutlet weak var nameOrganizationLabel: UILabel!
    @IBOutlet weak var roleInOrganizationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layoutIfNeeded()
        organizationPictureImageView.layer.cornerRadius = organizationPictureImageView.frame.width / 2
        organizationPictureImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
