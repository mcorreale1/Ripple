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

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
    func getLocationManager() -> CLLocationManager
}

class ChooseAddressViewController: BaseViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate,UIGestureRecognizerDelegate {
    
    var titleMessage :String = ""
    var message :String = ""
    
    var selectedPin:MKPlacemark? = nil
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var centerAnnotation:MKPointAnnotation!
    var address: String = ""
    var event: RippleEvent?
    //Set if coming from eventVC
    
    var fromEventVC = false
    
    let locationManager = CLLocationManager()
    var coordinate:CLLocationCoordinate2D!
    var eventCoordinate:CLLocationCoordinate2D!
    var createEventDelegate:CreateEventViewDelegate?
    var trackingCenter = false
    var location:String?
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton:UIButton!
<<<<<<< HEAD
   // @IBOutlet weak var searchBar:UISearchBar!
=======
    
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
    var addressSearchController : UISearchController? = nil
    var addressSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        addressSearchController = UISearchController(searchResultsController: locationSearchTable)
        addressSearchController?.searchResultsUpdater = locationSearchTable
<<<<<<< HEAD
        let addressSearchBar = addressSearchController?.searchBar
        addressSearchBar!.sizeToFit()
        addressSearchBar!.placeholder = "Search for places"
=======
        addressSearchBar = addressSearchController?.searchBar
//        searchBar.sizeToFit()
//        searchBar.placeholder = "Search for places"
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
        navigationItem.titleView = addressSearchController?.searchBar
        
        addressSearchController?.hidesNavigationBarDuringPresentation = false
        addressSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
<<<<<<< HEAD
        addressSearchBar!.delegate = self
=======
        //searchBar.delegate = self
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
        mapView.delegate = self
        mapView.showsBuildings = true
        
        if(locationManager.location == nil) {
            //locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        
        //self.chooseAddress(address, coordinate: coordinate)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1) //back button color
        nav?.barTintColor = UIColor.whiteColor()
        
        if (event != nil && fromEventVC) {
            coordinate = CLLocationCoordinate2D(latitude: event!.latitude, longitude: event!.longitude)
<<<<<<< HEAD
           // searchBar.hidden = true
=======
            addressSearchBar.hidden = true
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
            doneButton.titleLabel?.text = "Back"
        }
        else if(coordinate != nil) {
            print("Has coordinate")
            self.eventCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            doneButton.titleLabel?.text = "Back"
        }
        else if (coordinate == nil) {
            print("No coordinate)")
            coordinate = CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
            trackingCenter = true
        }
        centerAnnotation = MKPointAnnotation()
        centerAnnotation.coordinate = coordinate
        mapView.addAnnotation(centerAnnotation)
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    
    @IBAction func doneButtonClicked(sender:AnyObject) {
        if(event != nil && event!.latitude == coordinate.latitude && event!.longitude == coordinate.longitude) {
            self.navigationController?.popViewControllerAnimated(true)
        } else if (eventCoordinate != nil && eventCoordinate.latitude == coordinate.latitude && eventCoordinate.longitude == coordinate.longitude) {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        let alert = UIAlertController(title: "Name this location", message: message, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alert.textFields![0] as? UITextField {
                self.location = field.text
                self.createEventDelegate?.writeBackEventLocation(self.coordinate.latitude, longitude: self.coordinate.longitude, location: self.location!)
                self.navigationController?.popViewControllerAnimated(true)
                
            }
        }
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
<<<<<<< HEAD
           // textField.text = self.searchBar.text
=======
            textField.text = self.addressSearchBar.text
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        })
        alert.addAction(confirmAction)
        self.presentViewController(alert, animated: true, completion: {})
        
    }

    func showLocationEnterAlert(message:String) {
        let alert = UIAlertController(title: "Name this location", message: message, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alert.textFields![0] as? UITextField {
                self.location = field.text
            }
        }
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
<<<<<<< HEAD
          //  textField.text = self.searchBar.text
=======
            textField.text = self.addressSearchBar.text
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
        })
        alert.addAction(confirmAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
//    func prepareSearchBar() {
//        //searchBar.sizeToFit()
<<<<<<< HEAD
//     //   searchBar.delegate = self
//        //searchBar.tintColor = UIColor.whiteColor()
//      //  searchBar.searchBarStyle = .Minimal
=======
//        searchBar.delegate = self
//        //searchBar.tintColor = UIColor.whiteColor()
//        searchBar.searchBarStyle = .Minimal
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
//        //searchBar.setImage(UIImage(named: "SearchBarSearchController"), forSearchBarIcon: .Search, state: .Normal)
//        
//        if let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField {
//            textFieldInsideSearchBar.textColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
//            //textFieldInsideSearchBar.layer.borderColor = UIColor.whiteColor().CGColor
//            textFieldInsideSearchBar.backgroundColor = UIColor.clearColor()
//            //            textFieldInsideSearchBar.layer.borderWidth = 1
//            //            textFieldInsideSearchBar.layer.cornerRadius = 6
//            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string:"Search Events, Orgs and Friends!", attributes:[NSForegroundColorAttributeName: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha:1)])
//        }
//        navigationItem.titleView = searchBar
//        navigationController?.navigationBar.translucent = false
//        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - MapView functions
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(trackingCenter) {
            centerAnnotation.coordinate = mapView.centerCoordinate
            self.coordinate = centerAnnotation.coordinate
        }
    }

    // MARK: - searchbar functions
    
    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        guard let text = searchBar.text else {
//            return
//        }
//        
//        trackingCenter = false
//        let localSearch = MKLocalSearchRequest()
//        localSearch.region = mapView.region
//        localSearch.naturalLanguageQuery = text
//        let search = MKLocalSearch(request: localSearch)
//        search.startWithCompletionHandler({ [weak self] (response, _) in
//            guard let response = response else {
//                return
//            }
//            if(response.mapItems.count > 0) {
//                let firstCoordinate:CLLocationCoordinate2D = response.mapItems[0].placemark.coordinate
//                self?.mapView.setCenterCoordinate(firstCoordinate, animated: true)
//                self?.centerAnnotation.coordinate = firstCoordinate
//                for item in response.mapItems {
//                    print("Name: \(item.name) Location: \(item.placemark.coordinate.latitude)")
//                }
//            }
//        })
//        view.endEditing(true)
//        searchBar.endEditing(true)
//    }
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        trackingCenter = true
//    }
//    
    func handleTap(recognizer: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        view.endEditing(true)
<<<<<<< HEAD
        //searchBar.endEditing(true)
        
=======
        addressSearchBar.endEditing(true)
>>>>>>> 8bd8dabfe42f9cf0e258d5198a0727fb83696c9e
    }
    
    func mapView(map: MKMapView, didSelect: MKAnnotationView) {
        if let anno = didSelect.annotation {
            let alert = UIAlertController(title: "Remove loctaion", message: "Remove this location and pick a new one?", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (_) in}
            let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (action) in
                self.mapView.removeAnnotation(anno)
                self.trackingCenter = true
            }
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            self.presentViewController(alert, animated: true, completion: {})
        }
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
extension ChooseAddressViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        trackingCenter = false
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        self.coordinate = placemark.coordinate
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        self.centerAnnotation = annotation
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    func getLocationManager() -> CLLocationManager {
        return self.locationManager
    }
}
