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
        
        // add corner radius on `contentView`
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.insetBy(dx: 10, dy: 10)
        
    }
    
    func configureCell(resturant: Details){
        resturantName.attributedText = NSMutableAttributedString(string: resturant.resturantName, attributes: LabelTextAttributes)
        
        restBGImage.image = resturant.photo
        typeOfRest.attributedText = NSMutableAttributedString(string: resturant.resturantType, attributes: LabelTextAttributes)
        distanceLbl.attributedText = NSMutableAttributedString(string: "\(String(round(resturant.distance * 10) / 10)) كم", attributes: LabelTextAttributes)
    }
    
    let LabelTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.white,
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: 0
    ]

}
