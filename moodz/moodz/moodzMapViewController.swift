//
//  moodzMapViewController.swift
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
    let query : String = UserDefaults.standard.string(forKey: "moodzChoice")!
    
    //keep tracking of how many times we've updated the map
    var timesUpdated = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionLabel.isHidden = true
        self.locationManager.delegate = self
        self.mapView.delegate = self
        
        
        
        //request user permissions
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.mapType = MKMapType.standard
        
        print("updating location")
        self.mapView.showsUserLocation = true
        
        //begin updating user location
        self.locationManager.startUpdatingLocation()
        
        
    }
    
    //Override ViewDidAppear method in order to prevent race conditions
    override func viewDidAppear(_ animated: Bool) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    //MARK: Delegate Method(s)
    
    func locationManager(_manager: CLLocationManager, didUpdateLocations: [CLLocation]){
        print("location manager delegate method being called")
        
        let loc = didUpdateLocations[0].coordinate
        let region = MKCoordinateRegionMakeWithDistance(loc, 100, 100)
        
        //change UI on main thread
        DispatchQueue.main.async(execute: {
            //MARK: Animation change due to Simulator Lag
            self.mapView.setRegion(region, animated: false)
            
        })
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("mapview delegate method being called")
        
        //If we've already seen a few MapView delegate calls, stop spamming performSearch and jerking the map around
        if (timesUpdated >= 3) {return}

        //stop snapping of map to user location
        self.locationManager.stopUpdatingLocation()
        
        let location : CLLocation = locationManager.location!
        print("location : \(location.coordinate)")
        print("userLocation: \(userLocation.coordinate)")
        
        performSearch(userLocation)
        
        timesUpdated += 1
        
    }
    
    
    
    //MARK: Add found results to map
    func performSearch(_ inputLocation : MKUserLocation) -> Void {
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
        
        
        theSearch.start(completionHandler: {(request,error)->Void in
            if let error = error{
                print(error)
            }else if let request=request{
                
                for item in request.mapItems{
                    //debugging statements
                    print("Place : \(item.placemark)")
                    let distance = theLocation.distance(from: item.placemark.location!)
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
                    
                    //handle nil optionals and combine street names with street numbers
                    if item.placemark.subThoroughfare != nil{
                        annotation.subtitle = annotation.subtitle! + item.placemark.subThoroughfare! + " "
                    }
                    
                    if item.placemark.thoroughfare != nil{
                        annotation.subtitle = annotation.subtitle! + item.placemark.thoroughfare!
                    }
                    
                    annotation.coordinate = item.placemark.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    //'select' pin of closest relevant activity found
                    if (annotation.title == closestPlace && theLocation.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) == min){
                        self.mapView.selectAnnotation(annotation, animated: true)
                        self.locationManager.stopUpdatingLocation()
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
            self.questionLabel.isHidden = false
            
        })
    }
    
    
    
}

