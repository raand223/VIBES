

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

