//
//  GeneralTabBar.swift
//  VibeApp
//
//  Created by Yazeedo on 06/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import SVProgressHUD
import MapKit
class GeneralTabBar: UITabBarController {

    private var locationManager:CLLocationManager = CLLocationManager()
    var location:CLLocation!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var coordn = CLLocationCoordinate2D()
        let currentLocation = locationManager.location
        coordn.latitude =  CLLocationDegrees(exactly: currentLocation?.coordinate.latitude ?? 24.770837)!
        coordn.longitude = CLLocationDegrees(exactly:currentLocation?.coordinate.longitude ?? 46.679192)!
        location = CLLocation(latitude: coordn.latitude, longitude: coordn.longitude)
        
        self.findLikedResturant {
            
        }
    }
    

    
    
    func findLikedResturant(completion: @escaping ()-> Void) {
        let userID = Auth.auth().currentUser?.uid
        DataService.instance.REF_Users.child(userID!).child("Likes").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                
                return }
            
            
            if snapshot.count > 0 {
                
                for restID in snapshot {
                    if let restID = restID.value as? String{
                        self.getResturantFromForSquareByID(resturantID: restID)
                    }
                }
                
                completion()
            }
            
            
        }) { (error) in
           
            completion()
        }
    }
    
    func getResturantFromForSquareByID(resturantID: String){
        
        let url = "https://api.foursquare.com/v2/venues/\(resturantID)?v=20160607&client_id=ZMSMIQAE0PIKGYAUHBM4IMSFFQA4WXEZNG5FYUHGBABFPE3C&client_secret=KYOC41BAQCFKGM5FN0SUASNR5JAK1B4KMR204M3CEPQEL4GO&oauth_token=NKRP0KY5ZDZIBMCU3TZS4BMP4ZMIQZBQPLBTCPXSIGPWFJ1L"
        
        //        DispatchQueue.global(qos: .background).async {
        
        let data = URLSession.shared.query(address: url)
        if data == nil {
            
            let alert = UIAlertController(title: NSLocalizedString("Error!", comment: ""), message: NSLocalizedString("There is a problem during fetching info or internet issue.", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
            }
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.show(alert, sender: nil)
            }
        }else {
            let returant = self.parseResturantData(data: data!)
            LikedResturant.shared.resturantList.append(returant!)
        }
        
        
    }
    
    
    
    
    
    func parseResturantData(data: Data) -> Details?{
        var fName:String = ""
        var fResturantID = ""
        var fType:String = ""
        var fDistance:Double = 0.0
        var fRatingz:Double = 0.0
        var fTotalRatings:Int = 0
        var fReviewText:String = ""
        var fPhoto:String = ""
        var fLongtitude = 0.0
        var fLatitude = 0.0
        var fCheckInCount = 0
        var fCurrency = ""
        var fTwitterAccount = ""
        var fPhoneNumber = ""
        var fImage = UIImage(named: "logo")!
        if let jsonDic = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
            if let response = jsonDic!.value(forKey: "response") as? NSDictionary {
                
                if let venue = response.value(forKey: "venue") as? NSDictionary {
                    if let name = venue.value(forKey: "name") as? String{
                        fName = name
                        
                    }
                    
                    if let resturantID = venue.value(forKey: "id") as? String{
                        fResturantID = resturantID
                        
                    }
                    
                    if let contact = venue.value(forKey: "contact") as? NSDictionary{
                        
                        if let twitterAccount = contact.value(forKey: "twitter") as? String {
                            fTwitterAccount = twitterAccount
                        }
                        
                        if let phoneNumber = contact.value(forKey: "phone") as? String {
                            fPhoneNumber = phoneNumber
                        }
                    }
                    if let status = venue.value(forKey: "stats") as? NSDictionary{
                        
                        if let checkInCount = status.value(forKey: "checkinsCount") as? Int {
                            fCheckInCount = checkInCount
                        }
                    }
                    
                    
                    if let price = venue.value(forKey: "price") as? NSDictionary{
                        
                        if let priceMessege = price.value(forKey: "message") as? String {
                            fCurrency = priceMessege
                        }
                    }
                    
                    if let location = venue.value(forKey: "location") as? NSDictionary {
                        
                        if let latitude = location.value(forKey: "lat") as? Double {
                            fLatitude = latitude
                        }
                        if let longtitude = location.value(forKey: "lng") as? Double {
                            fLongtitude = longtitude
                        }
                        
                        if let distance = location.value(forKey: "distance") as? Double {
                            fDistance = distance/1000
                        }else {
                            fDistance = userDistance(lat: fLatitude, long: fLongtitude)/1000
                        }
                        
                    }
                    if let categories = venue.value(forKey: "categories") as? NSArray{
                        
                        if let details = categories[0] as? NSDictionary{
                            if let type = details.value(forKey: "pluralName") as? String{
                                fType = type
                                
                            }
                        }
                        
                        
                    }
                    if let rating = venue.value(forKey: "rating") as? Double {
                        fRatingz = Double(rating/2)
                    }
                    if let likesCount = venue.value(forKey: "ratingSignals") as? Int {
                        fTotalRatings = likesCount
                    }
                    if let photos = venue.value(forKey: "bestPhoto") as? NSDictionary {
                        if let suffix = photos.value(forKey: "suffix") as? String{
                            //print(suffix)
                            let suffixx = suffix.replacingOccurrences(of: "\\", with: "")
                            //print(suffixx)
                            //https://igx.4sqi.net/img/general/300x500\(suffixx)
                            let photoUrl = "https://fastly.4sqi.net/img/general/414x176\(suffixx)"
                            fPhoto = photoUrl
                            
                            
                            let imageData = URLSession.shared.query(address:fPhoto)
                            
                            if let imageData = imageData {
                                if let image = UIImage(data: imageData){
                                    fImage = image
                                }
                            }
                        }
                    }
                    
                    if let tips = venue.value(forKey: "tips") as? NSDictionary {
                        if let groups = tips.value(forKey: "groups") as? NSArray {
                            if groups.count > 1 {
                            if let tipsDict = groups[1] as? NSDictionary{
                                if let items = tipsDict.value(forKey: "items") as? NSArray{
                                    if items.count > 0 {
                                        
                                    
                                    if let object = items[0] as? NSDictionary{
                                        if let text = object.value(forKey: "text") as? String{
                                            fReviewText = text
                                            
                                            
                                        }
                                    }
                                    }else {
                                        fReviewText = "good"
                                    }
                                    
                                }
                                
                            }
                            }else{
                                 fReviewText = "good"
                            }
                            
                        }
                    }
                }
                
                
                let dataRate = URLSession.shared.query(address: self.getRateUrl(name: fName))
                let rating = self.getRating(data: dataRate!)
                
                let resturant = Details(resturantName: fName, resturantRating: fRatingz, totalRating: fTotalRatings, photoLink: fPhoto, resturantType: fType, distance: fDistance, photo: fImage, tweetRating: rating, feeling: "", langtitude: fLatitude, longtitude: fLongtitude, checkInCount: fCheckInCount, currency: fCurrency, resturantID: fResturantID)
                
                if fTwitterAccount != "" {
                    resturant.twitterAccount = fTwitterAccount
                }
                if fPhoneNumber != "" {
                    resturant.contactNumber = fPhoneNumber
                }
                if fReviewText != "" {
                    resturant.reviewsText.append(fReviewText)
                }
                return resturant
            }
            
        }
        return nil
    }

    func getRateUrl(name: String) -> String{
        if let newName  = name.slice(from: "(", to: ")") {
            
            let encodedString = newName.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]{} ").inverted) as! String
            return "https://imyazeed.pythonanywhere.com/getRate/\(encodedString)"
        }else{
            
            let encodedString = name.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,|./?%#[]{} ").inverted) as! String
            print(encodedString)
            return "https://imyazeed.pythonanywhere.com/getRate/\(encodedString)"
        }
    }
    func getRating(data: Data) -> Rating{
        let decoder = JSONDecoder()
        let rating = try! decoder.decode(Rating.self, from: data)
        return rating
    }
    
    
    
    func userDistance(lat: Double, long: Double) -> Double {
       let loc2 = CLLocation(latitude: lat, longitude: long)
        return location.distance(from: loc2)
    }
    
    

}
