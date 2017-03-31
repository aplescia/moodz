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
    @IBAction func myMood(_ sender: UIButton){
        let userDefaults = UserDefaults.standard
        
        
        if (sender.titleLabel!.text == "Studious"){
            userDefaults.set("Coffee", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Adventurous"){
            userDefaults.set("hiking", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Vivacious"){
            userDefaults.set("clubbing", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Active"){
            userDefaults.set("gym", forKey: "moodzChoice")
        }else if (sender.titleLabel!.text == "Relaxed"){
            userDefaults.set("entertainment", forKey: "moodzChoice")
        }
        
    }
}
