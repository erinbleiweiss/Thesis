//
//  GeoDDRLevelViewController.swift
//  Thesis
//
//  Created by Erin Bleiweiss on 3/30/16.
//  Copyright © 2016 Erin Bleiweiss. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Away

class GeoDDRLevelViewController: GenericLevelViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var locationUpdateTimer: NSTimer?
    var gotLocation = false
    var originLat: Double = 0
    var originLong: Double = 0
    var currentLocation: CLLocation?
    var destination: CLLocation?
    
    var currentLat: Double = 0
    var currentLong: Double = 0
    
    var dLat: Double = 0
    var dLong: Double = 0
    
    var bearing: Double?
    var bearing2: CLLocationDirection?
    
    let controller: GeoDDRGameController
    required init?(coder aDecoder: NSCoder){
        controller = GeoDDRGameController()
        super.init(coder: aDecoder)
    }
    
    @IBAction func displayAlert(sender: AnyObject) {
        
        let stringbearing = String(bearing2)
//        let stringbearing2 = String(radiansToDegrees(bearing2!))
        
        
        let alertController = UIAlertController(title: "BEARING", message:
            "\(stringbearing)", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.controller.level = 4
        
//        let gameView = UIView(frame: CGRectMake(0, yOffset, ScreenWidth, ScreenHeight - yOffset))
//        self.view.addSubview(gameView)
//        self.controller.gameView = gameView
        
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 1 // distance in meters
            locationManager.headingFilter = 5 // angle in degrees
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(GeoDDRLevelViewController.updateLocation), userInfo: nil, repeats: true)

        }
        
        
        
    }

    
    override func viewDidDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
        locationUpdateTimer!.invalidate()
        locationUpdateTimer = nil
    }
    

    func updateLocation() {
        locationManager.startUpdatingLocation()
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
////        print("locations = \(locValue.latitude) \(locValue.longitude)")
//        if !gotLocation{
//            self.originLat = locValue.latitude
//            self.originLong = locValue.longitude
//            self.gotLocation = true
//            
//            let current = CLLocation(latitude: originLat, longitude: originLong)
//            self.destination = Away.buildLocation(0.5, from: current, bearing: 210)
//        }
//        
//        self.currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
//        
//        self.currentLat = locValue.latitude
//        self.currentLong = locValue.longitude
//        
//        self.dLat = (currentLat - originLat) * 100000
//        self.dLong = (currentLong - originLong) * 100000
//        
////        print ("dLat: \(self.dLat), dLong: \(self.dLong)")
//        
////        if self.destination?.distanceFromLocation(self.currentLocation!) <= 0.1 {
////            print ("ARRIVED")
////        } else {
////            print ("not yet arrived")
////        }
////
////        if (self.dLat > 0){
////            print("NORTH")
////        }
////        if (self.dLat < 0){
////            print("SOUTH")
////        }
////        if (self.dLong > 0){
////            print("EAST")
////        }
////        if (self.dLong < 0){
////            print("WEST")
////        }
////        print("")
////        print("")
////        print("")
//        
//        
//        let origin = CLLocation(latitude: self.originLat, longitude: self.originLong)
//        self.bearing = self.getBearingBetweenTwoPoints1(origin, point2: self.currentLocation!)
//        print(self.bearing)
//        
//        // This should match your CLLocationManager()
//        locationManager.stopUpdatingLocation()
//        
//        
//    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.bearing2 = newHeading.magneticHeading
        locationManager.stopUpdatingLocation()
    }
    
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * M_PI / 180.0 as Double
    }
    
    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI as Double
    }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude)
        let lon2 = degreesToRadians(point2.coordinate.longitude)
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
    
    
    func getHeadingForDirectionFromCoordinate(fromLoc: CLLocation, toLoc: CLLocation) -> Double {
        let fLat = degreesToRadians(fromLoc.coordinate.latitude)
        let fLng = degreesToRadians(fromLoc.coordinate.longitude)
        
        let tLat = degreesToRadians(toLoc.coordinate.latitude)
        let tLng = degreesToRadians(toLoc.coordinate.longitude)
        
        let bearing = atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))
        
        return radiansToDegrees(bearing)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
