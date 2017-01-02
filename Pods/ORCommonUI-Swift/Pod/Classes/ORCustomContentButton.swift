//
//  ORCustomContentButton.swift
//  Pods
//
//  Created by Maxim Soloviev on 11/08/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import UIKit

public class ORCustomContentButton: UIControl {

    public override func awakeFromNib() {
        super.awakeFromNib()
        
        exclusiveTouch = true
    }
    
    public override var highlighted: Bool {
        didSet {
            UIView.animateWithDuration(0.1) { _ in
                self.alpha = self.highlighted ? 0.3 : 1.0
            }
        }
    }
}
