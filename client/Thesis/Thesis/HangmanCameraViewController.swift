//
//  ViewController.swift
//  Thesis
//
//  Created by Erin Bleiweiss on 9/22/15.
//  Copyright (c) 2015 Erin Bleiweiss. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

import Alamofire
import SwiftyJSON

class HangmanCameraViewController: GenericCameraViewController, CameraDelegate {
    
    var productName: String!  // Name of product scanned
    var upc: String?          // UPC of product scanned

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearUpc()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.clearUpc()
    }
    
    /**
        Reset upc on load
     */
    func clearUpc(){
        self.upc = ""
    }
        
    
    /**
        Read data and send back to level controller
     
        - Parameters:
            - upc: (String) scanned UPC code
     */
    override func doAfterScan(upc: String){
        // Assign read upc to class
        self.upc = upc
        self.performSegueWithIdentifier("barcodeScannedSegue", sender: nil)
        
        
    }
    
    
    /**
        Get product name from UPC
     
        - Parameters
            - upc: (String) UPC from camrea
     */
    func getProduct(upc: String, completionHandler: (responseObject: String?, error: NSError?) -> ()) {
        let url: String = hostname + rest_prefix + "/get_product_nameOLD"
        Alamofire.request(.GET, url, parameters: ["upc": upc], headers: headers).responseJSON { (_, _, result) in
            
            let json = JSON(result.value!)
            if let name = json["product_name"].string{
                completionHandler(responseObject: name, error: result.error as? NSError)
            } else {
                completionHandler(responseObject: "Not Found", error: result.error as? NSError)
            }
            
            
        }
        
    }
    
    
    /**
        Send data back to TestLevelViewController via segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // If UPC defined
        if let _ = upc{
            let destinationVC = segue.destinationViewController as! HangmanLevelViewController
            destinationVC.controller.upc = self.upc!
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

