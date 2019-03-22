//
//  ProfileVC.swift
//  VibeApp
//
//  Created by Shahad Aldkhaiel on 27/06/1440 AH.
//  Copyright © 1440 MacBook Pro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import SDWebImage

class ProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super .viewDidLoad()
    
    }
    
   
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logOutError {
            print(logOutError)
        }
        print("usser try to log out")
        
        let storayBoard = UIStoryboard(name: "Start", bundle: nil)

        self.dismiss(animated: false, completion: nil)

    }
    
}
    
    

