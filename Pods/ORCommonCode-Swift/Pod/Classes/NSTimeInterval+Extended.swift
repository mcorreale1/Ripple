//
//  NSTimeInterval+Extended.swift
//  Pods
//
//  Created by Maxim Soloviev on 01/04/16.
//
//

import Foundation

extension NSTimeInterval {
    
    public func or_durationComponents() -> (days: Int, hours: Int, minutes: Int) {
        let value: NSTimeInterval = self < 0 ? 0 : self
        
        let days = Int(value / (60 * 60 * 24))
        let hours = Int(value / (60 * 60)) - days * 24
        let minutes = Int(value / 60) - days * 24 * 60 - hours * 60
        
        return (days: days, hours: hours, minutes: minutes)
    }
    
    /**
     Only 2 top components are printed to string, or only 1 if others == 0
     */
    public func or_durationStringShort(daysLocalized daysLocalized: String = "d", hoursLocalized: String = "h", minutesLocalized: String = "m") -> String {
        var result = ""
        let components = or_durationComponents()

        if components.days > 0 {
            if components.hours > 0 {
                result = "\(components.days)" + daysLocalized + " \(components.hours)" + hoursLocalized
            } else {
                result = "\(components.days)" + daysLocalized
            }
        } else if components.hours > 0 {
            if components.minutes > 0 {
                result = "\(components.hours)" + hoursLocalized + " \(components.minutes)" + minutesLocalized
            } else {
                result = "\(components.hours)" + hoursLocalized
            }
        } else {
            result = "\(components.minutes)" + minutesLocalized
        }
        
        return result
    }
}
