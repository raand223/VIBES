//
//  users.swift
//  VibeApp
//
//  Created by MacBook Pro on 18/02/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation
class User {
    var email : String?
    var  profileurl : String?
    var username : String?
    
}
extension User{
    func transformUserInfo (dic : [String : Any]) -> User {
        let user = User()
        user.email = dic["email"] as? String
        user.profileurl = dic ["profileImge"] as? String
        user.username = dic ["userName"] as? String
        return user
    }
}
