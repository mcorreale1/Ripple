//
//  ChooseAddressViewController.swift
//  Ripple
//
//  Created by Apple on 26.09.16.
//  Copyright © 2016 Adam Gluck. All rights reserved.
//

import UIKit
import MapKit
import ORLocalizationSystem

class ChooseAddressViewController: BaseViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var titleMessage :String = ""
    var message :String = ""
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var centerAnnotation:MKPointAnnotation!
    var address: String = ""
    var event: RippleEvent?
    
    let locationManager = CLLocationManager()
    var coordinate:CLLocationCoordinate2D!
    var createEventDelegate:CreateEventViewDelegate?
    
    
    func chooseAddress(address: String, coordinate: CLLocationCoordinate2D){
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                self!.message = NSLocalizedString("Place Not Found", comment: "Place Not Found")
                let alertController = UIAlertController(title: nil, message: self!.message, preferredStyle: UIAlertControllerStyle.Alert)
                self!.titleMessage = NSLocalizedString("Dismiss", comment: "Dismiss")
                alertController.addAction(UIAlertAction(title: self!.titleMessage, style: UIAlertActionStyle.Default, handler: nil))
                self!.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            //3
            self!.pointAnnotation = MKPointAnnotation()
            self!.pointAnnotation.title = address
            self!.pointAnnotation.coordinate = coordinate            
            
            self!.pinAnnotationView = MKPinAnnotationView(annotation: self!.pointAnnotation, reuseIdentifier: nil)
            self!.mapView.centerCoordinate = self!.pointAnnotation.coordinate
            self!.mapView.addAnnotation(self!.pinAnnotationView.annotation!)
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton:UIButton!
    @IBOutlet weak var searchBar:UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        searchBar.delegate = self
        mapView.delegate = self
        mapView.showsBuildings = true
        
        
        if(event != nil && event!.location != nil) {
            coordinate = CLLocationCoordinate2D(latitude: event!.latitude, longitude: event!.longitude)
        } else {
            coordinate = CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
        }
        centerAnnotation = MKPointAnnotation()
        centerAnnotation.coordinate = coordinate
        mapView.addAnnotation(centerAnnotation)
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
        //self.chooseAddress(address, coordinate: coordinate)
    }
    
    
    @IBAction func doneButtonClicked(sender:AnyObject) {
        
        let count = (self.navigationController?.viewControllers)!.count
        let prevVC = self.navigationController!.viewControllers[count-2] as! CreateEventViewController
        print(prevVC.description)
        
        createEventDelegate?.writeBackEventLocation(mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
//        prevVC.event?.latitude = mapView.centerCoordinate.latitude
//        prevVC.event?.longitude = mapView.centerCoordinate.longitude
        event?.latitude = mapView.centerCoordinate.latitude as! Double
        event?.longitude = mapView.centerCoordinate.longitude as! Double
        self.navigationController?.popViewControllerAnimated(true)
    }

    func prepareSearchBar() {
        //searchBar.sizeToFit()
        searchBar.delegate = self
        //searchBar.tintColor = UIColor.whiteColor()
        searchBar.searchBarStyle = .Minimal
        //searchBar.setImage(UIImage(named: "SearchBarSearchController"), forSearchBarIcon: .Search, state: .Normal)
        
        if let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
            //textFieldInsideSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
            textFieldInsideSearchBar.backgroundColor = UIColor.clearColor()
            //            textFieldInsideSearchBar.layer.borderWidth = 1
            //            textFieldInsideSearchBar.layer.cornerRadius = 6
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string:"Search Events, Orgs and Friends!", attributes:[NSForegroundColorAttributeName: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha:1)])
        }
        navigationItem.titleView = searchBar
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1) //back button color
        nav?.barTintColor = UIColor.whiteColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - MapView functions
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        centerAnnotation.coordinate = mapView.centerCoordinate
    }

    // MARK: - searchbar functions
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let localSearch = MKLocalSearchRequest()
        localSearch.region = mapView.region
        localSearch.naturalLanguageQuery = searchText
    }
    
        


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
