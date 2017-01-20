//
//  ORButton.swift
//  Pods
//
//  Created by Maxim Soloviev on 31/10/2016.
//
//

import UIKit

open class ORButton : UIButton {
    
    @IBInspectable open var cornerRadiusEqualsMinDimension: Bool = false {
        didSet {
            if cornerRadiusEqualsMinDimension {
                layer.cornerRadius = min(bounds.width / 2, bounds.height / 2)
                layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable open var customCornerRadius: CGFloat = 0 {
        didSet {
            if !cornerRadiusEqualsMinDimension {
                layer.cornerRadius = customCornerRadius
                layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var borderColor: UIColor? = nil {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if cornerRadiusEqualsMinDimension {
            layer.cornerRadius = min(bounds.width / 2, bounds.height / 2)
        }
    }
}
