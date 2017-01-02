//
//  ORRadialGradientView.swift
//  Dowoodle
//
//  Created by Maxim Soloviev on 24/06/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import UIKit

@IBDesignable public class ORRadialGradientView: UIView {

    @IBInspectable public var innerColor: UIColor = UIColor.redColor().colorWithAlphaComponent(0)
    @IBInspectable public var innerColorLocation: CGFloat = 0
    @IBInspectable public var mediumColor: UIColor = UIColor.redColor().colorWithAlphaComponent(0.5)
    @IBInspectable public var mediumColorLocation: CGFloat = 0.5
    @IBInspectable public var outerColor: UIColor = UIColor.redColor()
    @IBInspectable public var outerColorLocation: CGFloat = 1
    
    public override func drawRect(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        defer {
            CGContextRestoreGState(context)
        }

        CGContextSaveGState(context)

        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [innerColor.CGColor, mediumColor.CGColor, outerColor.CGColor], [innerColorLocation, mediumColorLocation, outerColorLocation])!
        let gradCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
        let gradRadius = min(bounds.size.width / 2, bounds.size.height / 2)
        CGContextDrawRadialGradient(context, gradient, gradCenter, 0, gradCenter, gradRadius, CGGradientDrawingOptions.DrawsAfterEndLocation)
    }
}
