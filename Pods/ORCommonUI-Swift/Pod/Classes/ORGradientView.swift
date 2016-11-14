//
//  ORGradientView.swift
//  Pods
//
//  Created by Alexander Kurbanov on 4/8/16.
//  Copyright © 2016 Alexander Kurbanov. All rights reserved.
//

import Foundation
import UIKit

public class ORGradientView: UIView {
    
    @IBInspectable public var colorTop: UIColor = UIColor.redColor()
    @IBInspectable public var colorBottom: UIColor = UIColor.blueColor()
    
    // MARK: - View lifecycle
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.setGradient(colorTop, color2: colorBottom)
    }
    
    // MARK: - Helpers
    
    public func setGradient(color1: UIColor, color2: UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        defer {
            CGContextRestoreGState(context)
        }
        
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [color1.CGColor, color2.CGColor], [0, 1])!
        
        // Draw Path
        let path = UIBezierPath(rect: CGRectMake(0, 0, frame.width, frame.height))
        CGContextSaveGState(context)
        path.addClip()
        CGContextDrawLinearGradient(context, gradient, CGPointMake(frame.width / 2, 0), CGPointMake(frame.width / 2, frame.height), CGGradientDrawingOptions())
    }
}
