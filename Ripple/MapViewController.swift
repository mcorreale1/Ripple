//
//  MapViewController.swift
//  Ripple
//
//  Created by evgeny on 09.08.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ORLocalizationSystem

class MapViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var countMilesLabel: UILabel!
    @IBOutlet weak var sliderMiles: UISlider!
    
    let stepSlider: Float = 1
    let longitudeInOneMile : Float = 1 / 67.172
    let latitudeInOneMile : Float = 1 / 69
    let latitudeDelta = 0.112872
    let longitudeDelta = 0.109863
    
    //the annotations contains a title, subtitle, coordinates and the event that is there, will add in categories in the future
    var allEvents = [RippleEvent]()
    var filterEvents = [RippleEvent]()
    var locationManager = CLLocationManager()
    var annotations = [EventAnnotation]()
    var userLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLocationManager()
        sliderMiles.value = UserManager().radiusSearch
        countMilesLabel.text = String(sliderMiles.value) + " miles"
        mapView.delegate = self
        
        EventManager().allEvents {[weak self] (events) in
            self?.allEvents = events
            self?.filteredEvents()
            self?.showPins()
        }
        self.navigationItem.title = NSLocalizedString("Location", comment: "Location")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(goBack))
        //navigationItem.leftBarButtonItem = backButton
    }
    
    func prepareLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        
        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        var newRegion = MKCoordinateRegion()
        newRegion.center.latitude = newLocation.coordinate.latitude
        newRegion.center.longitude = newLocation.coordinate.longitude
        newRegion.span.latitudeDelta = latitudeDelta
        newRegion.span.longitudeDelta = longitudeDelta
        let epsilon = 0.0001
        userLocation = newLocation.coordinate
        
        // fabs takes absolute value of a float
        if fabs(newLocation.coordinate.latitude - oldLocation.coordinate.latitude) >= epsilon && fabs(newLocation.coordinate.longitude - oldLocation.coordinate.longitude) >= epsilon {
            mapView.setRegion(newRegion, animated: true)
            filteredEvents()
            showPins()
        }
    }
    
    // MARK: - Helpers
    
    func filteredEvents() {
        guard let userLocation = self.userLocation else {
            return
        }
        
        let minLatitude = Float(userLocation.latitude) - sliderMiles.value * latitudeInOneMile
        let maxLatitude = Float(userLocation.latitude) + sliderMiles.value * latitudeInOneMile
        let minLongitude = Float(userLocation.longitude) - sliderMiles.value * longitudeInOneMile
        let maxLongitude = Float(userLocation.longitude) + sliderMiles.value * longitudeInOneMile
        
        let searchPredicate = NSPredicate(format: "(latitude >= %f) AND (latitude <= %f) AND (longitude >= %f) AND (longitude <= %f)", minLatitude, maxLatitude, minLongitude, maxLongitude)
        filterEvents = (allEvents as NSArray).filteredArrayUsingPredicate(searchPredicate) as! [RippleEvent]
    }
    
    //this is where the pins are added, most likely can seperate the pins into their categories here to make things easy
    func showPins() {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        for event in filterEvents {
            let annotation = EventAnnotation()
            let latitude = event.latitude
            let longitude = event.longitude
            
            if let title = event.name {
                annotation.title = title
            }
            
            if let description = event.descr {
                annotation.subtitle = description
            }
            annotation.event = event
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("event") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "event")
            annotationView!.canShowCallout = true
            let rightButton: AnyObject! = UIButton(type: .DetailDisclosure)
            rightButton.titleForState(UIControlState.Normal)
            annotationView!.rightCalloutAccessoryView = rightButton as? UIView
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let eventAnnotation = view.annotation as? EventAnnotation {
            if let event = eventAnnotation.event as? RippleEvent {
                showEventDescriptionViewController(event)
            }
        }
    }
    
    // MARK: - Actions
    
    //not connected or called anywhere, supposed to be used whenever the radius is changed the map will update
    @IBAction func sliderMilesValueChanged(sender: UISlider) {
        let roundedValue = round(sender.value / stepSlider) * stepSlider
        sender.value = roundedValue
        let strMiles = NSLocalizedString("miles", comment: "miles")
        countMilesLabel.text = String(roundedValue) + " " + strMiles
        filteredEvents()
        showPins()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func goBack()
    {
        UserManager().radiusSearch = sliderMiles.value
        self.navigationController?.popViewControllerAnimated(true)
    }
}
