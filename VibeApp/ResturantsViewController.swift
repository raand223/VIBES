//
//  ResturantsViewController.swift
//  Vibes
//
//  Created by Umair Ahmad on 06/03/2019.
//  Copyright © 2019 Abdul Jabbar. All rights reserved.
//

import UIKit
import TwitterKit
import CoreLocation
import MapKit
import Alamofire
import FoursquareAPIClient
import Async
import SVProgressHUD
import FirebaseAuth
import FirebaseDatabase
enum ResturantCategory: String {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dineer"
    case coffee = "coffee"
}

class ResturantsViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate  {
    
    
    
    var category: String?
    var isLikedVC = true
    @IBOutlet weak var mapview: MKMapView!
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var tableView: UITableView!
    
    //locationManager
    private var locationManager:CLLocationManager!
    //save last location for limit the Google places api request
    private var lastLocation:CLLocation?
    
    
    //save reference of current pins
    private var pins = [MKPointAnnotation]()
    
    var resturantDetails:[Details] = []
    
    var filtereResturant = [Details]()
    var isFiltered = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarTitle()
        setupSegmentController()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = spinner
        searchBar.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        //set my location accurcy to best
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //show my location
        mapview.showsUserLocation = true
        mapview.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        
        
        let leftView = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 26))
        leftView.backgroundColor = .clear
        
        
        //self.secondstimer = Timer.scheduledTimer(timeInterval:5, target: self, selector: #selector(self.UpdateSecondsTimer), userInfo: nil, repeats: true)
       
        
        if isLikedVC {
            resturantDetails = LikedResturant.shared.resturantList
        }
        else {
             SVProgressHUD.show(withStatus: "إنتظر قليلًا...")
        self.findNearestResturantsForSquareApi(name: category ?? "lunch") {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
            
        }
    }
    }
    
    func setupSegmentController() {
        let relaxImage = UIImage.textEmbededImage(image: UIImage(named: "مريح")!, string: "مرتاح", color: UIColor.black)
        segmentedControl.setImage(relaxImage, forSegmentAt: 0)
        
        let loveImage = UIImage.textEmbededImage(image: UIImage(named: "منبهر")!, string: "منبهر", color: UIColor.black)
        segmentedControl.setImage(loveImage, forSegmentAt: 1)
        
        let happyImage = UIImage.textEmbededImage(image: UIImage(named: "سعيد")!, string: "مستانس", color: UIColor.black)
        segmentedControl.setImage(happyImage, forSegmentAt: 2)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        segmentedControl.selectedSegmentIndex = 3
        guard !searchText.isEmpty else {
            isFiltered = false
            tableView.reloadData()
            return
        }
        
        filtereResturant = resturantDetails.filter { resturnat -> Bool in
            resturnat.resturantName.lowercased().contains(searchText.lowercased())
        }
        isFiltered = true
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    func setupNavigationBarTitle() {
        
        if isLikedVC {
            self.navigationItem.title = "الاعجابات"
        }else {
            var navTitle = ""
            switch category {
            case ResturantCategory.breakfast.rawValue:
                navTitle = "الإفطار"
            case ResturantCategory.lunch.rawValue:
                navTitle = "الغداء"
            case ResturantCategory.dinner.rawValue:
                navTitle = "العشاء"
            case ResturantCategory.coffee.rawValue:
                navTitle = "المقاهي"
            default:
                break
            }
            self.title = navTitle
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    //Set the coordinates to the location and update the pins
    func setupForCurrentLocation(location:CLLocation){
        
        //        let region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(MAP_ZOOM_LEVEL, MAP_ZOOM_LEVEL))
        //        mapview.setRegion(region, animated: true)
        //
        //        var reviewsTexts : String = ""
        //        var finalData: [Details] = []
        //        combineData(location: location) { (detail) in
        //            for items in detail  {
        //
        //                reviewsTexts = items.reviewsText
        //
        //                let url = "http://services.analysisserver.xyz:8000/?text="+"\(reviewsTexts)"
        //
        //                guard let str = url.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {return}
        //                guard let data = URLSession.shared.query(address: str) else {return}
        //                if let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
        //                    //                    print(String(data: data!, encoding: .utf8)!)
        //                    let sentiment =  dict!.value(forKey: "sentiment") as! String
        //                    //let confidence = dict!.value(forKey: "confidence") as! String
        //
        //                    finalData.append(Details(resturantName: items.resturantName, resturantRating: items.resturantRating, totalRating:items.totalRating, reviewsText: "\(items.reviewsText + "  sentiment: \(sentiment)")", photoLink:items.photoLink))
        //                    //print(finalData)
        //                    //self.textVew.text = "\(finalData)"
        //                    //print(finalData)
        //                    DispatchQueue.main.async {
        //
        //
        //                        do {
        //                            let encoder = JSONEncoder()
        //                            encoder.outputFormatting = .prettyPrinted
        //                            let data = try encoder.encode(finalData)
        //                            let final  = (String(data: data, encoding: .utf8)!)
        //                            //print(final)
        //                            //self.textVew.text = "\(final)"
        //
        //                        } catch let error {
        //                            print("error converting to json: \(error)")
        //
        //                        }
        //                    }
        //                }
        //            }
        //        }
    }
    var resturantNamesArray = [String]()
    var logoImages = [UIImage]()
    
    //    func combineData(location:CLLocation, completetion: @escaping ([Details])->Void){
    //
    //        var dataArray:[Details] = []
    //        var dataArray1:[Details] = []
    //        guard let searchText = searchTextField.text else {return}
    //        DispatchQueue.global(qos: .background).async {
    //
    //
    //            dataArray = self.findNearestResturantsForSquareApi(name:searchText, completion: <#() -> Void#>)
    //            //print(dataArray)
    //            dataArray1 = self.findNearestResturantsByGooglePlaces(coord: (location.coordinate))
    //
    //            dataArray.append(contentsOf: dataArray1)
    //            print(dataArray)
    //            completetion(dataArray)
    //
    //
    //
    //
    //            for i in dataArray {
    //                self.resturantNamesArray.append(i.resturantName)
    //                self.logoImages.append(i.photoLink)
    //
    //
    //                DispatchQueue.main.async {
    //
    //                   self.tableView.reloadData()
    //                }
    //
    //
    //                //print(i.resturantName)
    //            }
    //        }
    //    }
    
    
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
    
    //    func findNearestResturantsByGooglePlaces(coord:CLLocationCoordinate2D) -> [Details]
    //    {
    //        var resturantDetails:[Details] = []
    //
    //
    //        let url = getUrlForResturants(coord: coord)       //get the google places javascript url for the location
    //        var locations = [Location]()
    //
    //
    //        let data = URLSession.shared.query(address: url)
    //        //        print(String(data: data!, encoding: .utf8)!)
    //
    //        if data == nil {
    //            let alert = UIAlertController(title: NSLocalizedString("Error!", comment: ""), message: NSLocalizedString("There is a problem during fetching info or internet issue.", comment: ""), preferredStyle: .alert)
    //
    //            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
    //            }
    //
    //        }else {
    //
    //            if let dict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String,AnyObject> {
    //
    //                if let results = dict?["results"] as? [Dictionary<String,AnyObject>]
    //                {
    //
    //                    for result in results
    //                    {
    //
    //                        if let geometry = result["geometry"] as? Dictionary<String,AnyObject>,let name = result["name"] as? String,let descr = result["vicinity"] as? String,let rating = result["rating"] as? Double,let totalRatings = result["user_ratings_total"] as? Int,let placeID = result["place_id"] as? String {
    //
    //                            let place_id = placeID
    //                            let urlString = "\(DETAILS_PLACE_URL)placeid=\(place_id)&key=\(GOOGLE_API_KEY)"
    //
    //                            let data = URLSession.shared.query(address: urlString)
    //                            //print(String(data: data!, encoding: .utf8)!)
    //                            if let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
    //                                //print(jsonDict)
    //                                var textReview:String = ""
    //                                if let actorDict = jsonDict!.value(forKey: "result") as? NSDictionary {
    //                                    if let actorArray = actorDict.value(forKey: "reviews") as? NSArray {
    //
    //                                        for i in actorArray{
    //                                            if let actorDict1 = i as? NSDictionary {
    //                                                if let reviewText = actorDict1.value(forKey: "text") as? String{
    //
    //                                                    textReview = reviewText
    //                                                }
    //                                            }
    //                                        }
    //                                    }
    //                                    //https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=PHOT0_REFRENCE_HERE&key=YOUR_API_KEY
    //
    //                                    if let photos = actorDict.value(forKey: "photos") as? NSArray {
    //                                        for i in photos{
    //                                            if let dict = i as? NSDictionary {
    //                                                if let photoRefrence = dict.value(forKey: "photo_reference") {
    //                                                    //print(photoRefrence)
    //
    //                                                    let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(photoRefrence)&key=\(GOOGLE_API_KEY)"
    //
    //                                                    resturantDetails.append(Details(resturantName: name, resturantRating: rating, totalRating: totalRatings, reviewsText: textReview, photoLink: photoURL))
    //                                                }
    //                                            }
    //                                        }
    //                                    }
    //                                }
    //                            }
    //
    //                            if let coord = geometry["location"] as? Dictionary<String,CGFloat>
    //                            {
    //                                locations.append(Location(title: name,coord: CLLocationCoordinate2D(latitude: CLLocationDegrees(CGFloat(coord["lat"]!)),longitude: CLLocationDegrees(CGFloat(coord["lng"]!))), desc: descr))
    //                            }
    //                        }
    //                    }
    //                }
    //                //self.setUpPins(locations: locations)
    //            }
    //
    //
    //        }
    //
    //
    //
    //        //print(resturantDetails)
    //        return resturantDetails;
    //    }
    //
    //
    func findNearestResturantsForSquareApi(name:String, completion: @escaping ()-> Void) {
        
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
      
        var coordn = CLLocationCoordinate2D()
        let currentLocation = locationManager.location
        coordn.latitude =  CLLocationDegrees(exactly: currentLocation?.coordinate.latitude ?? 24.770837)!
        coordn.longitude = CLLocationDegrees(exactly:currentLocation?.coordinate.longitude ?? 46.679192)!
        
        print("latitude \(coordn.latitude)")
        print("longitude \(coordn.longitude)")
        
        
        
let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(coordn.latitude),\(coordn.longitude)&section=food&v=20160607&intent=\(name)&limit=20&client_id=ZMSMIQAE0PIKGYAUHBM4IMSFFQA4WXEZNG5FYUHGBABFPE3C&client_secret=KYOC41BAQCFKGM5FN0SUASNR5JAK1B4KMR204M3CEPQEL4GO&oauth_token=NKRP0KY5ZDZIBMCU3TZS4BMP4ZMIQZBQPLBTCPXSIGPWFJ1L"
        
        
        
        DispatchQueue.global(qos: .background).async {
            
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
                                                
                                                if let distance = location.value(forKey: "distance") as? Double {
                                                    fDistance = distance/1000
                                                }
                                                if let latitude = location.value(forKey: "lat") as? Double {
                                                    fLatitude = latitude
                                                }
                                                if let longtitude = location.value(forKey: "lng") as? Double {
                                                    fLongtitude = longtitude
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
                                                let photoUrl = "https://igx.4sqi.net/img/general/414x176\(suffixx)"
                                                fPhoto = photoUrl
                                                
                                                
                                                let imageData = URLSession.shared.query(address:fPhoto)
                                                var finalImage = UIImage(named: "logo")!
                                                if let imageData = imageData {
                                                    if let image = UIImage(data: imageData){
                                                        finalImage = image
                                                    }
                                                }
                                                let dataRate = URLSession.shared.query(address: self.getRateUrl(name: fName))
                                                let rating = self.getRating(data: dataRate!)
                                                
                                                let resturant = Details(resturantName: fName, resturantRating: fRatingz, totalRating: fTotalRatings, photoLink: fPhoto, resturantType: fType, distance: fDistance, photo: finalImage, tweetRating: rating, feeling: "", langtitude: fLatitude, longtitude: fLongtitude, checkInCount: fCheckInCount, currency: fCurrency, resturantID: fResturantID)
                                                
                                                if fTwitterAccount != "" {
                                                    resturant.twitterAccount = fTwitterAccount
                                                }
                                                if fPhoneNumber != "" {
                                                    resturant.contactNumber = fPhoneNumber
                                                }
                                                if fReviewText != "" {
                                                    resturant.reviewsText.append(fReviewText)
                                                }
                                                self.resturantDetails.append(resturant)
                                                
                                                
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            completion()
        }
        
    }
    
    func findLikedResturant(completion: @escaping ()-> Void) {
        let userID = Auth.auth().currentUser?.uid
        DataService.instance.REF_Users.child(userID!).child("Likes").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                SVProgressHUD.dismiss()
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
          SVProgressHUD.dismiss()
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
               self.resturantDetails.append(returant!)
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
                        
                        if let distance = location.value(forKey: "distance") as? Double {
                            fDistance = distance/1000
                        }
                        if let latitude = location.value(forKey: "lat") as? Double {
                            fLatitude = latitude
                        }
                        if let longtitude = location.value(forKey: "lng") as? Double {
                            fLongtitude = longtitude
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
                            if let tipsDict = groups[1] as? NSDictionary{
                                if let items = tipsDict.value(forKey: "items") as? NSArray{
                                    
                                    if let object = items[0] as? NSDictionary{
                                        if let text = object.value(forKey: "text") as? String{
                                            fReviewText = text
                                            
                                            
                                        }
                                    }
                                }
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
    

 
    
    //This will call when user location changed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count==0
        {
            return
        }
        if let last = lastLocation
            //if last location is there then calculate the distance from last position to new postion if value is greater than certain then update the nearest libraries
        {
            //print(CGFloat(last.distance(from: locations[0])))
            
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
    
    var secondstimer:Timer?
    
    @objc func UpdateSecondsTimer() {
        print("TableView timer Started")
        DispatchQueue.main.async {
            //            dump(self.alltweets)
            self.tableView.reloadData()
        }
        
    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //
    //        return 1
    //    }
    
    
    func fetchTweets(name:String) {
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: "7S0Cq0a3Zwhc3luua8rJOE6J8", consumerSecret: "cyQKIP3AAo7lBj5AH12eeQr7LN830KQcHLDI1sdl5t48x3ZBXo")
        
        let client = TWTRAPIClient()
        let params = ["q": "\(name)", "result_type": "recent", "include_entities": "true", "count": "15"]
        var clientError : NSError?
        
        let request =  client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/search/tweets.json"
            , parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (res:URLResponse?, data:Data?, error:Error?) in
            
            //print(String(data:data! , encoding: String.Encoding.utf8)!)
            
            if data == nil || error != nil  {
                
                let alert = UIAlertController(title: NSLocalizedString("Error!", comment: ""), message: NSLocalizedString("\(error?.localizedDescription ?? "")", comment: ""), preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action) in
                }
                
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
                self.spinner.stopAnimating()
                
            }else {
                
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String,AnyObject> {
                    
                    if let results = dict?["statuses"] as? NSArray
                    {
                        for i in results{
                            if let actorDict = i as? NSDictionary {
                                //print(actorDict)
                                if let reviewText = actorDict.value(forKey: "text"){
                                    
                                    //print(reviewText)
                                    //                                self.alltweets.append(reviewText as! String)
                                    //                                print(self.alltweets)
                                    
                                    let url = "http://services.analysisserver.xyz:8000/?text="+"\(reviewText)"
                                    
                                    guard let str = url.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {return}
                                    guard let data = URLSession.shared.query(address: str) else {return}
                                    
                                    do {
                                        
                                        if let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                                            //                    print(String(data: data!, encoding: .utf8)!)
                                            let sentiment =  dict!.value(forKey: "sentiment") as! String
                                            
                                            
                                            //                                            self.alltweets.append("\(reviewText) : \(sentiment)")
                                            //                                            print(self.alltweets.count)
                                            
                                            
                                            self.spinner.stopAnimating()
                                            self.spinner.hidesWhenStopped = true
                                        }
                                        
                                    }catch let err as NSError {
                                        print(err.localizedDescription)
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                }
                
            }
            
            
        }
        
    }
    
    @IBAction func searchBtnAction(_ sender: UIButton) {
        
        
    }
    //    @IBAction func searchbtnPressed(_ sender: UIButton) {
    //
    //        if searchTextField.text != "" {
    //
    //            self.alltweets.removeAll()
    //            self.tableView.reloadData()
    ////            let user = searchTextField.text?.replacingOccurrences(of: " ", with: "")
    ////            getstuff(user: user ?? "")
    //            spinner.startAnimating()
    //            guard let names = searchTextField.text else {return}
    //
    //            fetchTweets(name:names)
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !isFiltered {
            return resturantDetails.count
        }
        return filtereResturant.count
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RestDetailsCell
        
        if !isFiltered {
            cell.configureCell(resturant: resturantDetails[indexPath.row])
        }else{
            cell.configureCell(resturant: filtereResturant[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    let LabelTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.white,
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: 0
    ]
    
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
    
    
    
    @IBAction func segmentAction(_ sender: Any) {
        searchBar.text = ""
        switch segmentedControl.selectedSegmentIndex
        {
        case 3:
            isFiltered = false
            
        case 2:
            isFiltered = true
            filtereResturant = resturantDetails.filter {  resturant -> Bool in
                resturant.feeling == "سعيد"
            }
        case 1:
            isFiltered = true
            filtereResturant =  resturantDetails.filter {  resturant -> Bool in
                resturant.feeling == "منبهر"
            }
        case 0:
            isFiltered = true
            filtereResturant =  resturantDetails.filter {  resturant -> Bool in
                resturant.feeling == "مريح"
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "restDetailsID"{
            let restDetailsVC = segue.destination as! ResturantDetailsTableViewController
            
            if isFiltered  {
                 restDetailsVC.resturant = filtereResturant[tableView.indexPathForSelectedRow!.row]
            }else{
              restDetailsVC.resturant = resturantDetails[tableView.indexPathForSelectedRow!.row]
            }
            
        }
    }
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
}

extension UIImage {
    
    class func textEmbededImage(image: UIImage, string: String, color:UIColor, imageAlignment: Int = 0, segFont: UIFont? = nil) -> UIImage {
        let font = segFont ?? UIFont.systemFont(ofSize: 16.0)
        let expectedTextSize: CGSize = (string as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
        let width: CGFloat = expectedTextSize.width + image.size.width + 5.0
        let height: CGFloat = max(expectedTextSize.height, image.size.width)
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2.0
        let textOrigin: CGFloat = (imageAlignment == 0) ? image.size.width + 5 : 0
        let textPoint: CGPoint = CGPoint.init(x: textOrigin, y: fontTopPosition)
        string.draw(at: textPoint, withAttributes: [NSAttributedStringKey.font: font])
        let flipVertical: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        context.concatenate(flipVertical)
        let alignment: CGFloat =  (imageAlignment == 0) ? 0.0 : expectedTextSize.width + 5.0
        context.draw(image.cgImage!, in: CGRect.init(x: alignment, y: ((height - image.size.height) / 2.0), width: image.size.width, height: image.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
