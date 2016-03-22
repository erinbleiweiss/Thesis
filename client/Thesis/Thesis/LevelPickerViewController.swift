//
//  LevelPickerViewController.swift
//  
//
//  Created by Erin Bleiweiss on 10/15/15.
//
//

import UIKit


protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
    
    /**
     Creates a new instance of the class on which this method is invoked,
     instantiated from a nib of the given name. If no nib name is given
     then a nib with the name of the class is used.
     
     - Parameter nibNameOrNil: The name of the nib to instantiate from, or
     nil to indicate the nib with the name of the class should be used.
     
     - Returns: A new instance of the class, loaded from a nib.
     */
    
    static func loadFromNib(nibNameOrNil: String? = nil) -> Self {
        let nibName = nibNameOrNil ?? self.className
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiateWithOwner(self, options: nil).first as! Self
    }
    
    static private var className: String {
        let className = "\(self)"
        let components = className.characters.split{$0 == "."}.map ( String.init )
        return components.last!
    }
    
}


class LevelPickerViewController: MootViewController, UIViewLoading {
    @IBAction func cancelToLevelPicker(segue:UIStoryboardSegue) {
    }
    
    var levelTiles: [LevelTile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        LevelManager.sharedInstance.unlockLevel(1)
        self.displayLevelTiles()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let tabBar = self.tabBarController as! MootTabBarController
        tabBar.removeCameraButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateTiles()
    }
    
    
    /**
        Using LevelManager singleton, display grid of UIButtons (custom class LevelTile). Add targets that respond to clickPressed()
     
        - Parameters: none
    */
    func displayLevelTiles(){
        let allLevels = LevelManager.sharedInstance.listLevels()
        
//        let length = allLevels.count
        let size = 3
        
        var row = 0
        var col = 0
        let margin = 20
        
        for (index, level) in allLevels.enumerate(){
            let frame = CGRect(x: 50 + (100 * (col+1) + (margin * index)), y: 200 + (100 * row), width: 100, height: 100)
            //            let button = UIButton(frame: frame)
            
            let levelView = LevelTile(level: level, frame: frame)
            levelTiles.append(levelView)
            levelView.addTarget(self, action: "clickPressed:", forControlEvents: .TouchUpInside)
            
            //            levelView.backgroundColor = UIColor(white: 1, alpha: 0.5)
            
            levelView.backgroundColor = UIColor.blueColor()
            
            if (level.isLocked()) {
                levelView.displayLock()
            }
            
            
            self.view.addSubview(levelView)
            col++
            if (col >= size){
                col=0
                row++
            }
            
        }
    }


    
    
    /**
        Target action, called for each of the LevelTile buttons.  If unlocked, presents root view controller, defined in Level object
     
        - Parameters:
            - sender: LevelTile (UIButton subclass)
    
    */
    func clickPressed(sender: LevelTile!){
        if (!sender.level!.isLocked()){
            self.navigationController?.pushViewController(sender.VC!, animated: true)
        }
        
    }
    
    /**
        For use in ViewDidLoad, update status of level tiles.  If tile is unlocked, change background color and update tile in self.levelTiles
     
        - Parameters: none
     
    */
    func updateTiles(){
        for (idx, tile) in self.levelTiles.enumerate() {
            let level = LevelManager.sharedInstance.listLevels()[idx]
            if (level.isLocked()) {
                tile.backgroundColor = UIColor.redColor()
            } else{
                tile.backgroundColor = UIColor.blueColor()
                tile.level = level
            }
        }
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
