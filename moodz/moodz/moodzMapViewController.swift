//
//  ViewController.swift
//  moodz
//
//  Created by Anthony Plescia on 2015-09-30.
//  Copyright © 2015 Anthony Plescia. All rights reserved.
//

import UIKit
import MapKit

class moodzMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var questionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    //get selected query from userdefaults
    let query : String = NSUserDefaults.standardUserDefaults().stringForKey("moodzChoice")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionLabel.hidden = true
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        
        
        //request user permissions
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.mapType = MKMapType.Standard
        
        print("updating location")
        self.mapView.showsUserLocation = true
        
        //begin updating user location
        self.locationManager.startUpdatingLocation()
        
        
    }
    
    //Override ViewDidAppear method in order to prevent race conditions
    override func viewDidAppear(animated: Bool) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    //MARK: Delegate Method(s)
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        print("location manager delegate method being called")
        
        let loc = newLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(loc, 100, 100)
        
        //change UI on main thread
        dispatch_async(dispatch_get_main_queue(), {
            //MARK: Animation change due to Simulator Lag
            self.mapView.setRegion(region, animated: false)
            
        })
        
        
    }
    
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        print("mapview delegate method being called")
        
        //stop snapping of map to user location
        self.locationManager.stopUpdatingLocation()
        //compare locations
        
        let location : CLLocation = locationManager.location!
        print("location : \(location.coordinate)")
        print("userLocation: \(userLocation.coordinate)")
        
        performSearch(userLocation)
        
        
    }
    
    
    
    //MARK: Add found results to map
    func performSearch(inputLocation : MKUserLocation) -> Void {
        
        let theRequest = MKLocalSearchRequest()
        theRequest.naturalLanguageQuery = query
        print("Region : \(self.mapView.region)")
        theRequest.region = self.mapView.region
        
        
        
        print("Request Region: \(theRequest.region)")
        
        let theLocation : CLLocation = inputLocation.location!
        
        let theSearch = MKLocalSearch(request: theRequest)
        
        //closestPlace will store the name of the closest relevant location to the user
        var min = DBL_MAX
        var closestPlace = "Nothing found :(" //dummy value
        
        
        theSearch.startWithCompletionHandler({(request,error)->Void in
            if let error = error{
                print(error)
            }else if let request=request{
                
                for item in request.mapItems{
                    //debugging statements
                    print("Place : \(item.placemark)")
                    let distance = theLocation.distanceFromLocation(item.placemark.location!)
                    print("Distance : \(distance)")
                    //update closestPlace if this item is closer than the current closestPlace
                    if (distance < min){
                        min = distance
                        closestPlace = item.placemark.name!
                    }
                    
                    //Set a custom title/subtitle for each pin on the map
                    let annotation = MKPointAnnotation()
                    annotation.subtitle = ""
                    annotation.title = item.placemark.name!
                    
                    //explicitly handle nil optionals
                    if item.placemark.subThoroughfare != nil{
                        annotation.subtitle = annotation.subtitle! + item.placemark.subThoroughfare! + " "
                    }
                    
                    if item.placemark.thoroughfare != nil{
                        annotation.subtitle = annotation.subtitle! + item.placemark.thoroughfare!
                    }
                    
                    annotation.coordinate = item.placemark.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    //'select' pin of closest activity found my method
                    if (annotation.title == closestPlace && theLocation.distanceFromLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) == min){
                        self.mapView.selectAnnotation(annotation, animated: true)
                    }
                    
                }
            }
            
            
            //show questionlabel, and update annotations on map
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            
            //If we found something...
            if (closestPlace != "Nothing found :("){
                self.questionLabel.text = "Why don't you visit \(closestPlace)?"
            }else{
                //We didn't find anything
                self.questionLabel.text = closestPlace
            }
            self.questionLabel.hidden = false
            
        })
    }
    
    
    
}

