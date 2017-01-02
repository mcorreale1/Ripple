//
//  UITableViewCell+BottomSeparator.swift
//  Pods
//
//  Created by Maxim Soloviev on 30.06.16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import Foundation

extension UITableViewCell {
    
    public func or_addBottomSeparatorWithColor(color: UIColor, insets: UIEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)) -> UIView! {
        let splitView = UIView(frame: self.bounds)
        splitView.translatesAutoresizingMaskIntoConstraints = false
        splitView.backgroundColor = color
        self.contentView.addSubview(splitView)
        
        let leftConstraint = NSLayoutConstraint(item: splitView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: insets.left)
        
        let rightConstraint = NSLayoutConstraint(item: splitView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -insets.right)
        
        let bottomConstraint = NSLayoutConstraint(item: splitView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: splitView, attribute: .Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 1 / UIScreen.mainScreen().scale)
        
        addConstraints([leftConstraint, rightConstraint, bottomConstraint, heightConstraint])
        
        return splitView;
    }
}
