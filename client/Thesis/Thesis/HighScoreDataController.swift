//
//  HighScoreGameController.swift
//  Thesis
//
//  Created by Erin Bleiweiss on 3/31/16.
//  Copyright © 2016 Erin Bleiweiss. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class HighScoreDataController: GenericGameController{

    var highScores: [[String: String]] = []
    let num_scores_to_retrieve = 4
    
    func getHighScores(completionHandler: (responseObject: JSON?, error: NSError?) -> ()) {
        let url: String = hostname + rest_prefix + "/get_high_scores"
        Alamofire.request(.GET, url, parameters: ["num_scores": num_scores_to_retrieve])
            .responseJSON { (_, _, result) in
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                    print(json["status"])
                    
                    for (item, subJson):(String, JSON) in json{
                        if (item == "scores"){
                            print(subJson)
                            self.createScores(subJson)
                        }
                    }
                    completionHandler(responseObject: json, error: result.error as? NSError)
                case .Failure(_):
                    NSLog("Request failed with error: \(result.error)")
                }
        }
    }
    
    func createScores(scores: JSON){
        for (_, subJson):(String, JSON) in scores {
            let name = subJson["name"].string
            let score = String(subJson["score"].int!)
            highScores.append([name!: score])
        }
    }
    
    

}