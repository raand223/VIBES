//
//  HomeCell.swift
//  VibeApp
//
//  Created by MacBook Pro on 18/02/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage


class HomeCell: UITableViewCell {
    
    @IBOutlet weak var profileImageOutLet: UIImageView!
    @IBOutlet weak var usernameLable: UILabel!
    @IBOutlet weak var postImageOutLet: UIImageView!
    @IBOutlet weak var captiontextField: UILabel!
    
    
    var postC: PostModel? {
        didSet {
            upDataPostData()
        }
    }
    
    func upDataPostData() {
        captiontextField.text = postC?.caption
        
        // post Image
        if let postIMGUrlString = postC?.posturl {
            let postIMG  = URL(string: postIMGUrlString)
            postImageOutLet.sd_setImage(with: postIMG)
        }
        setupUserInfo()
    }
    
    @objc func setupUserInfo() {
        if let userIDPost = postC?.userPostId {
            Database.database().reference().child("Users").child(userIDPost).observeSingleEvent(of: DataEventType.value) { (snapshot : DataSnapshot) in
                if let dic = snapshot.value as? [String : Any] {
                    let users = User()
                    let newUsers = users.transformUserInfo(dic: dic)
                    self.usernameLable.text = newUsers.username
                    if let userProfileIMG = newUsers.profileurl {
                        let userPIMG = URL(string: userProfileIMG)
                        self.profileImageOutLet.sd_setImage(with : userPIMG)
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageOutLet.layer.cornerRadius = 25
    }
    
}
