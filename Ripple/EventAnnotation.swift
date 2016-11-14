//
//  EventAnnotation.swift
//  Ripple
//
//  Created by evgeny on 10.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import MapKit

class EventAnnotation: NSObject, MKAnnotation {

    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var event: AnyObject?
    
    override init() {
        coordinate = CLLocationCoordinate2DMake(0, 0)
        super.init()
    }
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, event: AnyObject) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.event = event
        
        super.init()
    }
}
