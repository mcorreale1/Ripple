//
//  LocationSearchTable.swift
//  Ripple
//
//  Created by Michael on 2/27/17.
//  Copyright © 2017 Adam Gluck. All rights reserved.
//

import UIKit
import MapKit



class LocationSearchTable: UITableViewController {
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    var mapItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    func setAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let selectedItem = mapItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = setAddress(selectedItem)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = mapItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        
        
        var locationManager = handleMapSearchDelegate!.getLocationManager()
        if let location = locationManager.location {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            request.region = MKCoordinateRegionMake(location.coordinate, span)
        } else {
            request.region = mapView.region
        }
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response = response else {
                return
            }
            print("map desc: " + response.mapItems.description)
            self.mapItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}


