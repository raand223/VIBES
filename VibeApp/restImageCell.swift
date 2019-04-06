//
//  restImageCell.swift
//  VibeApp
//
//  Created by Yazeedo on 06/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class restImageCell: UICollectionViewCell {
    
    @IBOutlet weak var restImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        restImage.image = nil 
    }
    
    func configureUI(image: UIImage) {
        restImage.image = image
    }
}
