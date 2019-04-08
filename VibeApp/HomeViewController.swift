//
//  ViewController.swift
//  Vibes
//
//  Created by Abdul Jabbar on 15/02/2019.
//  Copyright © 2019 Abdul Jabbar. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func forSquareButtonTapped(_ sender: Any) {
        count = 0
    }

    @IBAction func googlePlaceApiButtonTapped(_ sender: Any) {
        count = 1
    }
    
}

