//
//  ORRoundRectButton.swift
//  Pods
//
//  Created by Maxim Soloviev on 11/04/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import UIKit

public class ORRoundRectView : UIView {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
}

public class ORRoundRectButton : UIButton {
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2
    }
}
