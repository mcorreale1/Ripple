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

class ChooseAddressViewController: BaseViewController, UISearchBarDelegate  {
    
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
    
    var address: String = ""
    var event: RippleEvent?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        // Init the zoom level
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: event!.latitude, longitude: event!.longitude)
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
        self.chooseAddress(address, coordinate: coordinate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
