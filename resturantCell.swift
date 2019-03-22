//
//  resturantCell.swift
//  Vibes
//
//  Created by Yaz on 2/21/19.
//  Copyright © 2019 Abdul Jabbar. All rights reserved.
//


import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase
class resturantCell: UITableViewCell {
     let n = ResturantTableViewController()
    var detail = "reem"
    
    @IBOutlet weak var resturantName: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var numOfLikesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(resturant: Details) {
        resturantName.text = resturant.resturantName
        ratingLabel.text = String(resturant.resturantRating)
       // numOfLikesLabel.text = String(resturant.totalReviewsOrLikes)
        detail = resturant.resturantName
    }
    
    @IBAction func like(_ sender: UIButton) {
        
        sendListToDatabase(name: detail , reslocation: "gg")
        
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alert.addAction(okAction)
//        n.present(alert, animated: true, completion: nil)
    }
    
    func sendListToDatabase (name : String , reslocation : String) {
        guard let userIdlist = Auth.auth().currentUser?.uid else { return}
        let ref : DatabaseReference!
        ref = Database.database().reference()
        let listRef = ref.child("favoriteList")
        let listID = listRef.childByAutoId().key
        let newlistRef = listRef.child(listID!)
        newlistRef.setValue([ "userId" : userIdlist ,"resturantName" : name, "resturantLocation":reslocation]) { (error, ref) in
            if error != nil {
                return
            }
            //self.tabBarController?.selectedIndex = 0
            // CameraVC.clear()
        }
    }
}
