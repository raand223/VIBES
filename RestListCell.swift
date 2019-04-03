//
//  RestListCell.swift
//  VibeApp
//
//  Created by Zeeshan Dar on 3/11/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class RestListCell: UICollectionViewCell {
    
    @IBOutlet weak var imgrest:UIImageView!
    @IBOutlet weak var lblRestName:UILabel!
    
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgrest.image = nil
        lblRestName.text = nil
    }
    
    func configureUI(resturant:Details) {
        imgrest.image = resturant.photo
        lblRestName.text = resturant.resturantName
    }
}
