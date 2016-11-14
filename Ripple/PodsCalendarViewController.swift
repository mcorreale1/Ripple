//
//  PodsCalendarViewController.swift
//  Ripple
//
//  Created by Adam Gluck on 9/7/15.
//  Copyright (c) 2015 Adam Gluck. All rights reserved.
//
import UIKit





class PodsCalendarViewController: CalendarViewController {
    
    class CalendarView : UIView
        
    {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let  calendar = CalendarView(frame: CGRectMake(0, 0, CGRectGetWidth(view.frame), 320))
        view.addSubview(calendar)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


