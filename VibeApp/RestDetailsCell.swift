//
//  TweetsTableViewCell.swift
//  Vibes
//
//  Created by Umair Ahmad on 06/03/2019.
//  Copyright © 2019 Abdul Jabbar. All rights reserved.
//

import UIKit

class RestDetailsCell: UITableViewCell {

    
    //@IBOutlet weak var tweetsLbl: UILabel!
    
    @IBOutlet weak var restBGImage: UIImageView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var feelingLbl: UILabel!
    @IBOutlet weak var typeOfRest: UILabel!
    @IBOutlet weak var resturantName: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
//        backgroundColor = .clear // very important
//        layer.masksToBounds = false
//        layer.shadowOpacity = 0.23
//        layer.shadowRadius = 1
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowColor = UIColor.black.cgColor
        
        // add corner radius on `contentView`
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.insetBy(dx: 10, dy: 10)
    }

}
