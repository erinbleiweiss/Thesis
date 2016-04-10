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
import CoreMotion

class GeoDDRLevelViewController: GenericLevelViewController, CLLocationManagerDelegate {
    
    var timerLabel: TimerLabel!
    var timer: NSTimer!
    

    let controller: GeoDDRGameController
    required init?(coder aDecoder: NSCoder){
        controller = GeoDDRGameController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controller.level = 4
        
        let y = ScreenHeight * 0.25
        let height = ScreenHeight * 0.5
        self.timerLabel = TimerLabel(frame: CGRectMake(0, y, ScreenWidth, height))
        self.timerLabel.textAlignment = .Center
        self.timerLabel.textColor = mootBlack
        self.timerLabel.font = UIFont(name: "Anonymous", size: 30.0)
        self.timerLabel.text = ""
        self.view.addSubview(self.timerLabel)
        
        self.startTimer(20)

    }
    
    
    func startTimer(duration: NSTimeInterval){
        self.timerLabel.startWithDuration(duration)
        self.timerLabel.update()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.checkTime), userInfo: nil, repeats: true)
    }
    
    func checkTime(){
        if !self.timerLabel.hasFinished(){
            self.timerLabel.update()
        }
    }
    
    func resetTime(){
        self.timer.invalidate()
        self.timer = nil
        self.timerLabel.resetTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(self.checkTime), userInfo: nil, repeats: true)
    }
    
    

    
    override func viewDidDisappear(animated: Bool) {
//        locationManager.stopUpdatingLocation()
//        locationUpdateTimer!.invalidate()
//        locationUpdateTimer = nil
    }
    
}
