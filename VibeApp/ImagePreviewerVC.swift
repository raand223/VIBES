//
//  ImagePreviewerVC.swift
//  VibeApp
//
//  Created by Yazeedo on 06/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class ImagePreviewerVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    var resturantImage: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()

       image.image = resturantImage
    }

}
