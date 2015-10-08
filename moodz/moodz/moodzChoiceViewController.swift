//
//  moodzChoiceViewController.swift
//  moodz
//
//  Created by Anthony Plescia on 2015-10-03.
//  Copyright © 2015 Anthony Plescia. All rights reserved.
//

import Foundation
import UIKit

class moodzChoiceViewController : UIViewController {
    
    //Function to save a rudimentary query to User Defaults depending on mood choice
    @IBAction func myMood(sender: UIButton){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        
        if (sender.titleLabel!.text == "Studious"){
            userDefaults.setObject("Coffee", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Adventurous"){
            userDefaults.setObject("hiking", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Vivacious"){
            userDefaults.setObject("clubbing", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Active"){
            userDefaults.setObject("gym", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Relaxed"){
            userDefaults.setObject("entertainment", forKey: "moodzChoice")
        }
        
    }
}
