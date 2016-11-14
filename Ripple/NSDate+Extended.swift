
//
//  NSDate+Extended.swift
//  iMaya
//
//  Created by evgeny on 20.05.16.
//  Copyright © 2016 Qooberty. All rights reserved.
//

import UIKit

extension NSDate
{
    func formatDateWithFormat(format: String) -> String {
        let dataFormatter = NSDateFormatter()
        dataFormatter.dateFormat = format
        return dataFormatter.stringFromDate(self)
    }
    
    func formatDayMonthYear() -> String {
        return formatDateWithFormat("dd MMMM yyyy")
    }
    
    func day() -> String {
        return formatDateWithFormat("dd")
    }
    
    func monthNumber() -> String {
        return formatDateWithFormat("MM")
    }
    
    func year() -> String {
        return formatDateWithFormat("yyyy")
    }
    
    func time() -> String {
        return formatDateWithFormat("HH:mm")
    }
    
    func formatEventDay() -> String {
        return formatDateWithFormat("EEEE\nLLLL, dd")
    }
    
    func formatEventTime() -> String {
        return formatDateWithFormat("hh:mm a")
    }
    
    func setTimeForDate(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let componentsDayDate = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: self)
        let componentsTimeDate = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        componentsDayDate.hour = componentsTimeDate.hour
        componentsDayDate.minute = componentsTimeDate.minute
        
        return calendar.dateFromComponents(componentsDayDate)!
    }
    
    func resetTime() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        let dateComponents = NSDateComponents()
        dateComponents.year = components.year
        dateComponents.month = components.month
        dateComponents.day = components.day
        return calendar.dateFromComponents(dateComponents)!
    }
    
    func tomorrow() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingUnit(.Day, value: 1, toDate: self, options: [])!
    }
}
