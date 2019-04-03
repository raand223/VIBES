//
//  SplashViewController.swift
//  VibesFirstDemo
//
//  Created by Shahad Aldkhaiel on 21/05/1440 AH.
//  Copyright © 1440 ShahadAldkhaiel. All rights reserved.
//

import UIKit
import FirebaseAuth
class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3){
            if Auth.auth().currentUser != nil {
                self.performSegue(withIdentifier: "alreadySignIn", sender: nil)
            }else{
                self.performSegue(withIdentifier:"SingIn", sender:nil)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
