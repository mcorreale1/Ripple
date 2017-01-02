//
//  CalendarCV.swift
//  Ripple
//
//  Created by Adam Gluck on 4/26/16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit

@IBOutlet weak var calendarView: CVCalendarView!
@IBOutlet weak var menuView: CVCalendarMenuView!

override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    calendarView.commitCalendarViewUpdate()
    menuView.commitMenuViewUpdate()
}

override func viewDidLoad() {
    super.viewDidLoad()
    
    // CVCalendarView initialization with frame
    self.calendarView = CVCalendarView(frame: CGRectMake(0, 20, 300, 450))
    
    // CVCalendarMenuView initialization with frame
    self.menuView = CVCalendarMenuView(frame: CGRectMake(0, 0, 300, 15))
    
    // Appearance delegate [Unnecessary]
    self.calendarView.calendarAppearanceDelegate = self
    
    // Animator delegate [Unnecessary]
    self.calendarView.animatorDelegate = self
    
    // Calendar delegate [Required]
    self.calendarView.calendarDelegate = self
    
    // Menu delegate [Required]
    self.menuView.menuViewDelegate = self
}
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    // Commit frames' updates
    self.calendarView.commitCalendarViewUpdate()
    self.menuView.commitMenuViewUpdate()
}