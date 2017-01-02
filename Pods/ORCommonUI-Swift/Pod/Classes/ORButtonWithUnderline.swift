//
//  ORButtonWithUnderline.swift
//  Pods
//
//  Created by Maxim Soloviev on 11/04/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import UIKit

public class ORButtonWithUnderline : UIButton {
    
    @IBInspectable var underlineThickness: CGFloat = 1
    @IBInspectable var underlineOffset: CGFloat = 1

    @IBInspectable public var underlineHidden: Bool = false {
        didSet {
            if underlineView != nil {
                underlineView.hidden = underlineHidden
            }
        }
    }
    
    weak var underlineView: UIView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
        let uv = UIView(frame: CGRectMake(0, bounds.height + underlineOffset, bounds.width, underlineThickness))
        uv.backgroundColor = titleColorForState(UIControlState.Normal)
        underlineView = uv
        addSubview(underlineView)
        underlineView.hidden = underlineHidden
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if underlineView != nil {
            underlineView.frame = CGRectMake(0, bounds.height + underlineOffset, bounds.width, underlineView.frame.height)
        }
    }
}
