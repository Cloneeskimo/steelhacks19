//
//  ViewController.swift
//  GeoArt
//
//  Created by Jacob Oaks on 3/1/19.
//  Copyright © 2019 Cloe. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    //location manager
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    
    //IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var button: UIButton!
   
    //react to button press
    @IBAction func onPress(_ sender: Any) {
        performSegue(withIdentifier: "artSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ArtViewController;
        vc.long = self.currentLocation.longitude
        vc.lat = self.currentLocation.latitude
    }
    
    //didLoad function - runs when view loads
    override func viewDidLoad() {
        super.viewDidLoad() //super
        checkLocationServices() //check location
    }
    
    //checks to make sure location services are working properly
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() { //if device-wide enabled
            setupLocationManager() //setup location manager
            checkLocationAuthorization() //verify app-specific permission
        } else {
            //TODO: tell user to enable location
        }
    }
    
    //sets up location manager
    func setupLocationManager() {
        locationManager.delegate = self //for event-handling purposes
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //set accuracy to best
    }
    
    //ensure app-specific permission
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //when app is open is only time app is authorized to get location
            mapView.showsUserLocation = true //show blue dot on map
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation() //start to fire off
            break
        case .authorizedAlways: //can get location always (even in background)
            break
        case .notDetermined: //havent asked yet
            locationManager.requestWhenInUseAuthorization() //ask user for authorization
            break
        case .restricted: //user cannot change status (i.e. parental controls, etc.)
            //TODO: tell them what's up
            break
        case .denied: //user refused to give permission - cannot ask them again
            //TODO: tell them to give us permission
            break
        }
    }
    
    //centers view relative to user's location
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000) //create an appropriate region
            mapView.setRegion(region, animated: true) //set the region to the new region
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    //when location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.last == nil) { return } //return if there is no last location
        self.currentLocation = locations.last!.coordinate //set location
        let center = CLLocationCoordinate2D(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude) //actual point where user is
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true) //region for display
    }
    
    //if authorization changes, ensure location authorization again
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
