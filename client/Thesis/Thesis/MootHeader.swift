//
//  MootHeader.swift
//  Thesis
//
//  Created by Erin Bleiweiss on 3/27/16.
//  Copyright © 2016 Erin Bleiweiss. All rights reserved.
//

import UIKit

class MootHeader: UIView {

    var scoreBox: ScoreBox?
    var levelBadge: LevelBadge?
    var resetButton: UIButton?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        
        let subviewHeight = self.bounds.height/2
        let subviewWidth = self.bounds.width/2
        
        let height = self.frame.height * 0.3
        var x: CGFloat = 0
        var y: CGFloat = 10
        let mootLogo = UILabel(frame: CGRectMake(x, y, ScreenWidth, height * 2))
        mootLogo.text = "Moot"
        mootLogo.font = Raleway.Black.withSize(height)
        mootLogo.textColor = UIColor.whiteColor()
        mootLogo.textAlignment = .Center
        self.addSubview(mootLogo)
        
        let scoreBoxFrame = CGRect(x: 0, y: self.bounds.height - subviewHeight, width: subviewWidth, height: subviewHeight)
        self.scoreBox = ScoreBox(frame: scoreBoxFrame)
        self.addSubview(scoreBox!)
        
        let badgeFrame = CGRect(x: subviewWidth, y: self.bounds.height - subviewHeight, width: subviewWidth, height: subviewHeight)
        self.levelBadge = LevelBadge(frame: badgeFrame)
        self.addSubview(levelBadge!)
        
        let resetImg = UIImage(named: "replay")!
        let resetImgPressed = UIImage(named: "replay")!.imageWithColor(UIColor(white: 1, alpha: 0.5))
        self.resetButton = UIButton(type: UIButtonType.Custom)
        let buttonSize = self.frame.height / 3
        let margin = buttonSize / 2
        x = ScreenWidth - margin - buttonSize
        y = (yOffset / 2) - (buttonSize / 2) + 5
        self.resetButton!.frame = CGRectMake(x, y, buttonSize, buttonSize)
        self.resetButton!.setImage(resetImg, forState: .Normal)
        self.resetButton!.setImage(resetImgPressed, forState: .Highlighted)
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
