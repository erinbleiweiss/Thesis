//
//  HangmanGameController.swift
//  Thesis
//
//  Created by Erin Bleiweiss on 11/12/15.
//  Copyright © 2015 Erin Bleiweiss. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class HangmanGameController: GenericGameController {
    
    var upc: String = ""
    var loading: Bool = false;
    var productName: String = ""

    var hangmanData = HangmanData()

    /// Array containing tile objects, each containing a letter
    var gameTiles = [HangmanTile]()
    
    /**
        Generate a random word via the Wordnik API, and set up constants for game
        
        - Parameters: none
    
        - Returns: a responseObject (JSON), containing the target word for the current game
        { word: "randomword" }
    
    */
    func getRandomWord(completionHandler: (responseObject: JSON?, error: NSError?) -> ()) {
        let url: String = hostname + rest_prefix + "/generate_random_word"
        let difficulty = self.getCurrentStage()
     
        Alamofire.request(.GET, url, parameters: ["difficulty": difficulty], headers: headers).responseJSON { (_, _, result) in
          switch result {
                case .Success(let data):
                    let json = JSON(data)
                    print(json)
                    let word = json["word"].stringValue
                    print(word)
                    self.hangmanData.set_TargetWord(word)
                    self.hangmanData.set_CurrentGame("")
                    self.saveLevelData(self.hangmanData, levelNum: 1)
                    completionHandler(responseObject: json, error: result.error as? NSError)
                case .Failure(_):
                    // There was a problem retrieving a word from the database
                    NSLog("getRandomWord failed with error: \(result.error)")
                    completionHandler(responseObject: JSON([:]), error: result.error as? NSError)
            }
                
        }
    }
    
    
    /** 
        Using the letter from the most recently scanned UPC, verify whether the
        guessed letter is in the target word. 
    
        - Parameters: 
            - upc: (String) barcode of scanned product
    
        - Returns: a responseObject (JSON), containing the letters in the 
        current game, in the form 
        {
            guess: "S"
            status: 1
            letters_guessed: "STR_NG"
        }
    
        - status return codes:
            - 0: Letter already in word
            - 1: Correct guess
            - 2: Incorrect guess
    
    */
    func playHangman(upc: String, completionHandler: (responseObject: JSON?, error: NSError?) -> ()) {
        self.loading = true;
        let url: String = hostname + rest_prefix + "/play_hangman"
        Alamofire.request(.GET, url, parameters: ["upc": upc, "target_word": self.hangmanData.getTargetWord(), "letters_guessed": self.hangmanData.getCurrentGame()], headers: headers).responseJSON { (_, _, result) in
            
            switch result {
                case .Success(let data):
                    let json = JSON(data)
                    // Update state of current game
                    self.hangmanData.set_CurrentGuess(json["guess"].stringValue)
                    let game_state = json["letters_guessed"].stringValue
                    self.hangmanData.set_CurrentGame(game_state)
                    for (index, letter) in game_state.characters.enumerate() {
                        self.gameTiles[index].updateLetter(letter)
                    }
                    
                    self.saveLevelData(self.hangmanData, levelNum: self.level!)
                    completionHandler(responseObject: json, error: result.error as? NSError)
                case .Failure(_):
                    SwiftSpinner.show("Could not scan. Try again!")
                    self.delay(2){
                         SwiftSpinner.hide()
                    }
                    NSLog("Request failed with error: \(result.error)")
                    completionHandler(responseObject: JSON([:]), error: result.error as? NSError)
               
            }
            
        }
        
    }
    
    /** 
        Called after each "move" to determine whether the game is complete (all tiles are filled)
        
        - Parameters: none
        - Returns: a return code indicating the appropriate behavior
            - 0: Current stage is not complete, take no action
            - 1: Current stage is complete, and level should advance to next stage
            - 2: Current stage is complete, and is the final stage in the level.  Should complete and advance to next level.
            - 3: Default return code (Something unexpected happened)
    
    */
    func checkForSuccess() -> Int{
     
        self.refreshData()

        for tile in gameTiles{
            if !tile.isFilled{
                return 0 // Stage is not complete
            }
        }
        // Stage is complete, check for level completion
        let level_complete = self.checkLevelCompleted()
        if (!level_complete){
          self.advanceToNextStage()
          self.upc = ""
          self.clearTiles()
          self.refreshData()
          return 1 // Not final stage; Level not complete
        } else {
          self.upc = ""
          self.refreshData()
          self.succeed() // Final stage; Level is complete
          return 2
        }
     
    }
    

    /**
        To be called between levels:
            - remove all tiles from view
            - clear gameTiles array
     */
    func clearTiles(){
        for tile in self.gameTiles {
            tile.removeFromSuperview()
        }
        self.gameTiles.removeAll()
        self.hangmanData.set_CurrentGame("")
        self.hangmanData.set_TargetWord("")
        self.hangmanData.set_CurrentGuess("")
    }
    
 
     /**
          Retrieve level from core data
      */
     func loadLevelData(){
          let path = "mootLevel\(self.level!)Data"
          let file = documentsDirectory().stringByAppendingPathComponent(path)
          if let levelData = NSKeyedUnarchiver.unarchiveObjectWithFile(file) as? HangmanData {
               self.hangmanData = levelData
          }
     }
     
     /**
          Save and load data
     */
     func refreshData(){
          self.saveLevelData(self.hangmanData, levelNum: self.level!)
          self.loadLevelData()
     }
     
     /**
         Reset level to default values
     */
     func reset(){
          self.hangmanData.resetData()
          self.refreshData()
          self.clearTiles()
     }
     
     
}

