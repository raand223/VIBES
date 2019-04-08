//
//  ListModel.swift
//  VibeApp
//
//  Created by Shahad Aldkhaiel on 21/06/1440 AH.
//  Copyright © 1440 MacBook Pro. All rights reserved.
//

import Foundation
class ListModel {
    
    var resturantName : String?
    var resturantLocation : String?
    var userId : String?
    
    init(userIdText: String, restaurantNameText: String, resturantLocationText: String){

        resturantLocation = resturantLocationText
        resturantName = restaurantNameText
        userId = userIdText
    }
}

