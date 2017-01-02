//
//  ORMath.swift
//  Pods
//
//  Created by Maxim Soloviev on 10/09/16.
//
//

import UIKit

@objc public class ORMath: NSObject {
    
    // only static methods are available
    private override init() {
    }
    
    /**
     @param t: 0.0 - 1.0
     */
    @objc public static func lerp(a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        let res = (a + (b - a) * t)
        return res
    }
    
    /**
     @param t: 0.0 - 1.0
     */
    @objc public static func cerp(a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        let res = (a + (b - a) * pow(t, 3))
        return res
    }
    
    @objc public static func distance(a: CGPoint, _ b: CGPoint) -> CGFloat {
        let distance = hypot(a.x - b.x, a.y - b.y)
        return distance
    }
    
    public static func clamp<T: Comparable>(value: T, _ lower: T, _ upper: T) -> T {
        return min(max(value, lower), upper)
    }
}
