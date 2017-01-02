//
//  UIView+HideKeyboard.swift
//  Pods
//
//  Created by Maxim Soloviev on 12/04/16.
//  Copyright © 2016 Maxim Soloviev. All rights reserved.
//

import UIKit

extension UIView {
    
    public func or_hideKeyboardWhenTapped() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(or_hideKeyboardHandler))
        addGestureRecognizer(tap)
        return tap
    }
    
    public func or_hideKeyboardHandler() {
        endEditing(true)
    }
}
