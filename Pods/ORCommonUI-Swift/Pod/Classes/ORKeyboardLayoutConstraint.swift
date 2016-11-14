//
//  ORKeyboardLayoutConstraint.swift
//  Pods
//
//  Created by Alexander Kurbanov on 4/5/16.
//  
//

import UIKit

public class ORKeyboardLayoutConstraint: NSLayoutConstraint {
    
    private var originalOffset: CGFloat = 0
    
    // MARK: - Object lifecycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.originalOffset = self.constant
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notificationKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notificationKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
 
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - NSNotification methods
    
    func notificationKeyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame = frameValue.CGRectValue()
                self.constant = frame.size.height + self.originalOffset
                
                self.updateLayout(userInfo)
            }
        }
    }
    
    func notificationKeyboardWillHide(notification: NSNotification) {
        self.constant = self.originalOffset
        
        if let userInfo = notification.userInfo {
            self.updateLayout(userInfo)
        }
    }
    
    func updateLayout(userInfo: [NSObject : AnyObject]) {
        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber, curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
            UIView.animateWithDuration(
                NSTimeInterval(duration.doubleValue),
                delay: 0,
                options: UIViewAnimationOptions(rawValue: curve.unsignedLongValue),
                animations: {[weak self] in
                    var topView = self?.firstItem.superview! as UIView!
                    while let superview = topView?.superview where !(superview is UIWindow) {
                        topView = superview
                    }
                    topView.layoutIfNeeded()
                },
                completion: nil)
        }
    }
}
