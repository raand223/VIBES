//
//  Resturant.swift
//  NearBy_Place_Finder
//
//  Created by AJ on 3/11/18.
//  Copyright © 2018 AJ. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation
import Alamofire
import FoursquareAPIClient
import Async
class Resturant: UIViewController,  MKMapViewDelegate,CLLocationManagerDelegate {
    
    
    @IBOutlet weak var restCollectionView: UICollectionView!
    
    @IBOutlet weak var textVew: UITextView!
    @IBOutlet weak var mapview: MKMapView!
    
    
    
    //locationManager
    private var locationManager:CLLocationManager!
    
    //save last location for limit the Google places api request
    private var lastLocation:CLLocation?
    
    //save reference of current pins
    private var pins = [MKPointAnnotation]()
    
    
    var resturantDetails:[Details] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = " "
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //set my location accurcy to best
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //start the location service
        locationManager.startUpdatingLocation()
        
        //show my location
        mapview.showsUserLocation = true
        
        mapview.delegate = self
        
        self.findNearestResturantsForSquareApi(coord: mapview.centerCoordinate)
    }
    
    // this method shows the pin and details view in AccessoryView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor  = .purple
            
            //next line sets a button for the right side of the callout...
            
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //This will call when user location changed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count==0
        {
            return
        }
        if let last = lastLocation
            //if last location is there then calculate the distance from last position to new postion if value is greater than certain then update the nearest libraries
        {
            print(CGFloat(last.distance(from: locations[0])))
            
            if CGFloat(last.distance(from: locations[0])) > UPDATE_RESTURANT_RATE          //calculate distance
            {
                lastLocation = locations[0]
                setupForCurrentLocation(location: (locations[0]))                       //set up the camera ,pins
            }
            
        }
        else{
            setupForCurrentLocation(location: (locations[0]))
            lastLocation = locations[0]
        }
        
    }
    
    
    //Set the coordinates to the location and update the pins
    func setupForCurrentLocation(location:CLLocation){
        
        let region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(MAP_ZOOM_LEVEL, MAP_ZOOM_LEVEL))
        mapview.setRegion(region, animated: true)
        
        var reviewsTexts : String = ""
        var finalData: [Details] = []
        combineData(location: location) { (detail) in
            for items in detail  {
                
                reviewsTexts = items.reviewsText
                
                let url = "http://services.analysisserver.xyz:8000/?text="+"\(reviewsTexts)"
                
                guard let str = url.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {return}
                let data = URLSession.shared.query(address: str)
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    //                    print(String(data: data!, encoding: .utf8)!)
                    let sentiment =  dict!.value(forKey: "sentiment") as! String
                    //let confidence = dict!.value(forKey: "confidence") as! String
                    
                    finalData.append(Details(resturantName: items.resturantName, resturantRating: items.resturantRating, totalRating:items.totalRating, reviewsText: "\(items.reviewsText + "  sentiment: \(sentiment)")", photoLink:items.photoLink))
                    print(finalData)
                    //self.textVew.text = "\(finalData)"
                    //print(finalData)
                    DispatchQueue.main.async {
                        
                        
                        do {
                            let encoder = JSONEncoder()
                            encoder.outputFormatting = .prettyPrinted
                            let data = try encoder.encode(finalData)
                            let final  = (String(data: data, encoding: .utf8)!)
                            print(final)
                            self.textVew.text = "\(final)"
                            
                        } catch let error {
                            print("error converting to json: \(error)")
                            
                        }
                    }
                }
            }
        }
    }
    
    func combineData(location:CLLocation, completetion: @escaping ([Details])->Void){
        
        var dataArray:[Details] = []
        var dataArray1:[Details] = []
        
        DispatchQueue.global(qos: .background).async {
            
            dataArray = self.findNearestResturantsForSquareApi(coord: (location.coordinate))
            dataArray1 = self.findNearestResturantsByGooglePlaces(coord: (location.coordinate))
            
            dataArray.append(contentsOf: dataArray1)
            //print(dataArray)
            completetion(dataArray)
            
        }
    }
    
    
    //Remove all last pins if there and setup new pins
    func setUpPins(locations:[Location])
    {
        for pin in pins{
            mapview.removeAnnotation(pin)
        }
        
        pins.removeAll()
        
        for loction in locations
        {
            let annotaion = MKPointAnnotation()
            annotaion.coordinate = loction.coord
            annotaion.title = loction.title
            annotaion.subtitle = loction.desc
            
            mapview.addAnnotation(annotaion)
            pins.append(annotaion)
        }
        
    }
    
    func findNearestResturantsByGooglePlaces(coord:CLLocationCoordinate2D) -> [Details]
    {
        var resturantDetails:[Details] = []
        
        
        let url = getUrlForResturants(coord: coord)       //get the google places javascript url for the location
        var locations = [Location]()
        
        
        let data = URLSession.shared.query(address: url)
        //        print(String(data: data!, encoding: .utf8)!)
        
        if data == nil {
            let alert = UIAlertController(title: NSLocalizedString("Error!", comment: ""), message: NSLocalizedString("There is a problem during fetching info or internet issue.", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
            }
            
        }else {
            
            if let dict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String,AnyObject> {
                
                if let results = dict?["results"] as? [Dictionary<String,AnyObject>]
                {
                    
                    for result in results
                    {
                        
                        if let geometry = result["geometry"] as? Dictionary<String,AnyObject>,let name = result["name"] as? String,let descr = result["vicinity"] as? String,let rating = result["rating"] as? Double,let totalRatings = result["user_ratings_total"] as? Int,let placeID = result["place_id"] as? String {
                            
                            let place_id = placeID
                            let urlString = "\(DETAILS_PLACE_URL)placeid=\(place_id)&key=\(GOOGLE_API_KEY)"
                            
                            let data = URLSession.shared.query(address: urlString)
                            //print(String(data: data!, encoding: .utf8)!)
                            if let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                                //print(jsonDict)
                                var textReview:String = ""
                                if let actorDict = jsonDict!.value(forKey: "result") as? NSDictionary {
                                    if let actorArray = actorDict.value(forKey: "reviews") as? NSArray {
                                        
                                        for i in actorArray{
                                            if let actorDict1 = i as? NSDictionary {
                                                if let reviewText = actorDict1.value(forKey: "text") as? String{
                                                    
                                                    textReview = reviewText
                                                }
                                            }
                                        }
                                    }
                                    //https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=PHOT0_REFRENCE_HERE&key=YOUR_API_KEY
                                    
                                    if let photos = actorDict.value(forKey: "photos") as? NSArray {
                                        for i in photos{
                                            if let dict = i as? NSDictionary {
                                                if let photoRefrence = dict.value(forKey: "photo_reference") {
                                                    //print(photoRefrence)
                                                    
                                                    let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(photoRefrence)&key=\(GOOGLE_API_KEY)"
                                                    
                                                    resturantDetails.append(Details(resturantName: name, resturantRating: rating, totalRating: totalRatings, reviewsText: textReview, photoLink: photoURL))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if let coord = geometry["location"] as? Dictionary<String,CGFloat>
                            {
                                locations.append(Location(title: name,coord: CLLocationCoordinate2D(latitude: CLLocationDegrees(CGFloat(coord["lat"]!)),longitude: CLLocationDegrees(CGFloat(coord["lng"]!))), desc: descr))
                            }
                        }
                    }
                }
                //self.setUpPins(locations: locations)
            }
            
            
        }
        
        
        
        //print(resturantDetails)
        return resturantDetails;
    }
    
    
    func findNearestResturantsForSquareApi(coord:CLLocationCoordinate2D) -> [Details] {
        
        var fName:String = ""
        var fRatingz:Double = 0.0
        var fTotalRatings:Int = 0
        var fReviewText:String = ""
        var fPhoto:String = ""
        var coordn = CLLocationCoordinate2D()
        coordn.latitude =  CLLocationDegrees(exactly: 24.770837)!
        coordn.longitude = CLLocationDegrees(exactly:46.679192)!
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(coordn.latitude),\(coordn.longitude)&section=food&v=20160607&intent=coffee&limit=20&client_id=ZMSMIQAE0PIKGYAUHBM4IMSFFQA4WXEZNG5FYUHGBABFPE3C&client_secret=KYOC41BAQCFKGM5FN0SUASNR5JAK1B4KMR204M3CEPQEL4GO&oauth_token=NKRP0KY5ZDZIBMCU3TZS4BMP4ZMIQZBQPLBTCPXSIGPWFJ1L"
        
        let data = URLSession.shared.query(address: url)
        
        if data == nil {
            
            let alert = UIAlertController(title: NSLocalizedString("Error!", comment: ""), message: NSLocalizedString("There is a problem during fetching info or internet issue.", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
            }
        }else {
            if let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                
                //print(String(data: data!, encoding: .utf8)!)
                
                if let actorArray = jsonDict!.value(forKey: "response") as? NSDictionary {
                    //print(actorArray)
                    
                    if let actorArray = actorArray.value(forKey: "group") as? NSDictionary {
                        
                        if let itmes = actorArray.value(forKey: "results") as? NSArray {
                            for i in itmes{
                                if let actorDict = i as? NSDictionary {
                                    if let venue = actorDict.value(forKey: "venue") as? NSDictionary {
                                        if let name = venue.value(forKey: "name") as? String{
                                            fName = name
                                            
                                        }
                                        
                                        if let rating = venue.value(forKey: "rating") as? Double {
                                            fRatingz = Double(rating/2)
                                        }
                                        if let likesCount = venue.value(forKey: "ratingSignals") as? Int {
                                            fTotalRatings = likesCount
                                        }
                                    }
                                    if let snippets = actorDict.value(forKey: "snippets") as? NSDictionary {
                                        if let itmes = snippets.value(forKey: "items") as? NSArray {
                                            for i in itmes{
                                                if let tipsDict = i as? NSDictionary{
                                                    if let details = tipsDict.value(forKey: "detail") as? NSDictionary{
                                                        if let object = details.value(forKey: "object") as? NSDictionary{
                                                            if let text = object.value(forKey: "text") as? String{
                                                                fReviewText = text
                                                                
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if let photos = actorDict.value(forKey: "photo") as? NSDictionary {
                                        if let suffix = photos.value(forKey: "suffix") as? String{
                                            //print(suffix)
                                            let suffixx = suffix.replacingOccurrences(of: "\\", with: "")
                                            //print(suffixx)
                                            //https://igx.4sqi.net/img/general/300x500\(suffixx)
                                            let photoUrl = "https://igx.4sqi.net/img/general/300x500\(suffixx)"
                                            fPhoto = photoUrl
                                            
                                            self.resturantDetails.append(Details(resturantName: fName, resturantRating: fRatingz, totalRating: fTotalRatings, reviewsText: fReviewText, photoLink: fPhoto))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //print(resturantDetails)
        self.restCollectionView.reloadData()
        return resturantDetails;
    }
}



extension Resturant:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        return resturantDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.restCollectionView.dequeueReusableCell(withReuseIdentifier: "RestListCell", for: indexPath) as? RestListCell
        
        cell?.lblRestName.text = self.resturantDetails[indexPath.row].resturantName
        
        return cell!
    }
    
    
    
}
