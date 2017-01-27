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

class ChooseAddressViewController: BaseViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate,UIGestureRecognizerDelegate {
    
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
    var trackingCenter = true
    var location:String?
    
    
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
        
        if(locationManager.location == nil) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestLocation()
        }
        
        
        if(event != nil && event!.location != nil) {
            coordinate = CLLocationCoordinate2D(latitude: event!.latitude, longitude: event!.longitude)
            trackingCenter = false
            searchBar.hidden = true
            doneButton.titleLabel?.text = "Back"
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
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    
    @IBAction func doneButtonClicked(sender:AnyObject) {
        if(event != nil) {
            self.navigationController?.popViewControllerAnimated(true)
        }
        let alert = UIAlertController(title: "Name this location", message: message, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alert.textFields![0] as? UITextField {
                self.location = field.text
                self.createEventDelegate?.writeBackEventLocation(self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude, location: self.location!)
                self.navigationController?.popViewControllerAnimated(true)

            }
        }
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = self.searchBar.text
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
            textField.text = self.searchBar.text
        })
        alert.addAction(confirmAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
        if(trackingCenter) {
            centerAnnotation.coordinate = mapView.centerCoordinate
        }
    }

    // MARK: - searchbar functions
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == "") {
            print("empty")
            trackingCenter = true
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        
        trackingCenter = false
        let localSearch = MKLocalSearchRequest()
        localSearch.region = mapView.region
        localSearch.naturalLanguageQuery = text
        let search = MKLocalSearch(request: localSearch)
        search.startWithCompletionHandler({ [weak self] (response, _) in
            guard let response = response else {
                return
            }
            if(response.mapItems.count > 0) {
                let firstCoordinate:CLLocationCoordinate2D = response.mapItems[0].placemark.coordinate
                self?.mapView.setCenterCoordinate(firstCoordinate, animated: true)
                self?.centerAnnotation.coordinate = firstCoordinate
                for item in response.mapItems {
                    print("Name: \(item.name) Location: \(item.placemark.coordinate.latitude)")
                }
            }
        })
        view.endEditing(true)
        searchBar.endEditing(true)
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        trackingCenter = true
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        view.endEditing(true)
        searchBar.endEditing(true)
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
