//
//  Constants.swift
//  NearBy_Place_Finder
//
//  Created by AJ on 3/10/18.
//  Copyright © 2018 AJ. All rights reserved.
//


// Google Places API URL
/* https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=32.0837,72.6719&radius=5000&type=mandi&key=AIzaSyCp7hrsSePGkvwnWmJ4OA3UAAMzE7JoHss
 */

import Foundation
import CoreLocation
import UIKit
import FoursquareAPIClient

//typealias OnFinished = ()->()   //Closure for Callback
//let BASE_URL = "https://www.googleapis.com/books/v1/volumes?q="  //Base Url of the Json Query Link

//Update the library every this value step
let UPDATE_RESTURANT_RATE = CGFloat(100)

let GOOGLE_API_KEY = "AIzaSyCp7hrsSePGkvwnWmJ4OA3UAAMzE7JoHss"       //google api key
let SHEARCH_DISTANCE = CGFloat(5000)                                  //radius of search
let FIND_PLCAE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"   //google places api url
let MAP_ZOOM_LEVEL = 0.07                                              //camera zoom
let SHARE_MESSAGE = "Hey Checkout this awesome book!"
let DETAILS_PLACE_URL = "https://maps.googleapis.com/maps/api/place/details/json?"

var count:Int = 0

let CLIENT = FoursquareAPIClient(clientId: "ZMSMIQAE0PIKGYAUHBM4IMSFFQA4WXEZNG5FYUHGBABFPE3C", clientSecret: "KYOC41BAQCFKGM5FN0SUASNR5JAK1B4KMR204M3CEPQEL4GO", version: "20140723")


//get the google places api url for coordinate
func getUrlForResturants(coord:CLLocationCoordinate2D)->String
{
    return "\(FIND_PLCAE_URL)?location=\(coord.latitude),\(coord.longitude)&radius=\(SHEARCH_DISTANCE)&type=restaurant&key=\(GOOGLE_API_KEY)"
}
class Details {
    var resturantId:String
    var resturantName:String = ""
    var resturantRating:Double
    var totalRating:Int
    var reviewsText:[String]
    var photoLink:String
    var resturantType: String
    var distance: Double
    var photo: UIImage?
    var tweetRating: Rating?
    var feeling: String?
    var feelingRating: Int
    var contactNumber: String?
    var twitterAccount:String?
    var langtitude:Double
    var longtitude:Double
    var checkInCount:Int
    var currency:String
    var startHours:String?
    var EndHours:String?


    
    init(resturantName: String, resturantRating: Double, totalRating: Int, photoLink: String, resturantType: String,  distance: Double,photo: UIImage?,tweetRating: Rating?,feeling: String, langtitude: Double, longtitude: Double,checkInCount: Int,currency: String,resturantID: String){
        self.resturantId = resturantID
        self.resturantName = resturantName
        self.resturantRating = resturantRating
        self.totalRating = totalRating
        self.reviewsText = [String]()
        self.photoLink = photoLink
        self.resturantType = resturantType
        self.distance = distance
        self.photo = photo
        self.tweetRating = tweetRating
        self.feeling = feeling
        self.contactNumber = ""
        self.twitterAccount = ""
        self.langtitude = langtitude
        self.longtitude = longtitude
        self.checkInCount = checkInCount
        self.currency = currency
        self.startHours = ""
        self.EndHours = ""
        self.feelingRating = 0
        getFeeling()
    }
    
    func getFeeling(){
        
        guard let rating = tweetRating else {
            self.feeling = "عادي"
            self.feelingRating = 50
            return
        }
        let dic: [String:Double] = ["angry":rating.angry,"comfortable":rating.comfortable,"contirition":rating.contirition,"happy":rating.happy,"impressed":rating.impressed,"sad":rating.sad]
        let totalRate = rating.angry+rating.comfortable+rating.contirition+rating.happy+rating.impressed+rating.sad
        
        if let generalFeeling =  dic.max(by: { a, b in a.value < b.value }) {
            if totalRate == 0 {
                self.feeling = "عادي"
                self.feelingRating = 50
               
            }else{
                self.feeling = NSLocalizedString(generalFeeling.key, comment: "")
                self.feelingRating = Int(generalFeeling.value/totalRate * 100)
                
            }
            
        }
        
        
    }
    
}




extension URLSession{
    
    func query(address: String) -> Data? {
        let url = URL(string: address)
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Data?
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            result = data
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return result
    }
    
}
