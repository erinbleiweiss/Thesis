//
//  GenericGameController.swift
//  Thesis
//
//  Created by Erin Bleiweiss on 1/31/16.
//  Copyright © 2016 Erin Bleiweiss. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SCLAlertView

class GenericGameController{
    var gameView: UIView!

    var defaults: NSUserDefaults?
    var username: String?
    var password: String?
    var popViewController: PopUpViewControllerSwift?
    var level: Int?
    var headers: [String: String]?
    
    // Status codes used to verify properly-formatted responseObjects from Alamofire API calls
    var SUCCESS: String = "success"
    var FAILURE: String = "failure"
    
    init() {
        self.username = get_uuid()
        self.password = get_api_key()
        
        // Pre-authorize all API Requests with appropriate headers
        let credentialData = "\(self.username!):\(self.password!)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        let headers = ["Authorization": "Basic \(base64Credentials)"]
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = headers
        self.headers = headers
        
        self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)

    }
    
    func setLevelProgress(level: Int) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(level, forKey: "highest_level")
    }
    
    func getLevelProgress() -> Int{
        let defaults = NSUserDefaults.standardUserDefaults()
        let highestLevel = defaults.integerForKey("highest_level")
        return highestLevel
    }
    
    
    /**
        Convert Postgres timestamps into NSDate Objects, and return as simplified "MM, DD YYYY" string in the user's timezone
     
        - Parameters:
            - jsonDate: (String)
     
        - Returns: A formatted date String
     
    */
    func convertDate(jsonDate: String) -> String{
        let dateFromStringFormatter = NSDateFormatter()
        dateFromStringFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        let date = dateFromStringFormatter.dateFromString(jsonDate) as NSDate!
        
        let stringFromDateFormatter = NSDateFormatter()
        stringFromDateFormatter.timeZone = NSTimeZone.localTimeZone()
        stringFromDateFormatter.dateFormat = "MMMM d, yyyy"
        let dateString = stringFromDateFormatter.stringFromDate(date)
        
        return dateString
    }
    
    
    
    /**
     Wrapper around Apple's dispatch_after() function in order to execute a code
     block after a specified amount of time
     
     - Parameters:
     - delay: (Double) time in seconds
     
     - Returns: none
     
     */
    func delay(delay: Double, closure: ()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    
    
    
    /**
        Create a time-stamped entry in the database recording a scanned product for a user.  These entries will be used to track progress towards earning achievements.
     
        - Parameters:
            - username: (String)
            - password: (String)
            - upc: (String) UPC (or ISBN) of the product
            - product_name: (String) Name of the product
            - color: (String) The color of the product
            - type: (String) Used to assign products to special categories used for achievements.  Ex: Food, Books,
     
     
        - Returns: a responseObject (JSON) containing a success code
        {
            status: "success"
        }
     
     
    */
    func saveProduct(upc: String, product_name: String, color: String, type: String, completionHandler: (responseObject: JSON?, error: NSError?) -> ()) {
        
        let url: String = hostname + rest_prefix + "/save_product"
        
        Alamofire.request(.POST, url, parameters: nil, encoding: .JSON, headers: headers)
            .responseJSON { (_, _, result) in
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                    print(json["status"])
                    
                    completionHandler(responseObject: json, error: result.error as? NSError)
                case .Failure(_):
                    NSLog("Request failed with error: \(result.error)")
                }
        }
    }
    
    
    /**
        Get current score from DB
     */
    func getMootPoints(completionHandler: (responseObject: JSON?, error: NSError?) -> ()){
        let url: String = hostname + rest_prefix + "/get_points"
        Alamofire.request(.GET, url, parameters: nil, encoding: .JSON, headers: headers)
            .responseJSON { (_, _, result) in
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                    completionHandler(responseObject: json, error: result.error as? NSError)
                case .Failure(_):
                    NSLog("Request failed with error: \(result.error)")
                }
        }
        
    }
    
    
    
    /**
        Determine whether an achievement was earned, and if so, display the appropriate popup message
     
        - Parameters: 
            - achievements_earned: (JSON) A JSON object from the level's game controller containing a list of all achievements earned
     
    */
    func displayAchievements(acheivements_earned: JSON){
        if (acheivements_earned.count == 0) {
            NSLog("No achievements earned")
        } else {
            for ach in acheivements_earned.arrayValue {
                NSLog(ach.string!)
                let message = "You just earned the \(ach.string!) achievement!"
                self.showAchievementPopUp(ach.string!, message: message)
            }
        }
    }

    //// ==========================================================
    //// POPUP DISPLAYS:
    //// ==========================================================
    
    
    /**
        Use the SCLAlertView class to display a popup for the given achievements
     
        - Parameters:
            - title: (String) Name of achievement
            - message: (String) Description to be displayed
            - image: (UI Image) Image associated with achievement
    */
    func showAchievementPopUp(title: String, message: String){
        let alertView = SCLAlertView()
        alertView.addSocialMedia()
        alertView.showTitle(
            title,
            subTitle: message,
            duration: 0.0,
            completeText: "Ok",
            style: .Custom,
            colorStyle: 0x000000,
            colorTextButton: 0xFFFFFF,
            circleIconImage: UIImage(named: "medal2"),
            topLabel: "Achievement Unlocked!"
        )
    }

    
    /**
        Use the SCLAlertview class to display a popup for each item scanned
     
        - Parameters:
            - productName: (String) Name of product
            - color: (UIColor) Color of scanned product
     
    */
    func showProductPopup(productName: String, color: UIColor, url: String){
        var img = UIImage()
        if let data = NSData(contentsOfURL: NSURL(string: url)!) {
            img = UIImage(data: data)!
        }
        let colorString = color.toHexString()
        let alertView = SCLAlertView()
        alertView.addImage(img)
        alertView.addLowerTitle(productName)
        alertView.showTitle(
            "Product Scanned!",
            subTitle: "",
            style: .Success,
            duration: 0.0,
            colorStyle: UInt(colorString),
            colorTextButton: 0xFFFFFF
        )
    }
    

    
    
    //// ==========================================================
    //// LEVEL MANIPULATING FUNCTIONS:
    //// ==========================================================
    
    /**
        Get current stage of level from Level Manager
    
        - Returns: (Int) current stage
    */
    func getCurrentStage() -> Int{
        return LevelManager.sharedInstance.getCurrentStage(self.level!)
    }
    
    
    /**
        Get number of stages in current level from Level Manager
     
        - Returns: (Int) number of stages
     */
    func getNumStages() -> Int{
        return LevelManager.sharedInstance.getNumStages(self.level!)
    }
    
    
    /**
        This function should be called at the completetion of any stage in a level.  It will determine whether or not the compeleted stage is the final stage in the level, and thus whether the level is complete
     
        - Parameters: none
        - Returns: (Boolean) indicatiing whether level is complete
     
     */
    func checkLevelCompleted() -> Bool{
        let currentStage = self.getCurrentStage()
        let numStages = self.getNumStages()
        return currentStage == numStages
    }
    
    
    /**
        Increments the current stage for level in level manager
     */
    func advanceToNextStage(){
        print("pressed")
        LevelManager.sharedInstance.advancetoNextStage(self.level!)
    }
    
    
    /**
        Helper function to be called when the final stage of a level is complete.
        Calls LevelManager, gets the next available Level object, and sets its unlock property to True

    */
    func succeed() {
        LevelManager.sharedInstance.unlockNextLevel(self.level!)
    }
    
    
    
}