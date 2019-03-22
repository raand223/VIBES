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


class ResturantsViewController: UIViewController,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate,CLLocationManagerDelegate  {

    @IBOutlet weak var mapview: MKMapView!
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    //locationManager
    private var locationManager:CLLocationManager!
    
    //save last location for limit the Google places api request
    private var lastLocation:CLLocation?
    
    //save reference of current pins
    private var pins = [MKPointAnnotation]()
    
    var resturantDetails:[Details] = []
    
    var filtereRes = [Details]()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.layer.cornerRadius = 8
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.black.cgColor
        filtereRes = resturantDetails
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = spinner
        
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
        
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        searchTextField.contentVerticalAlignment = .center
       
          //self.secondstimer = Timer.scheduledTimer(timeInterval:5, target: self, selector: #selector(self.UpdateSecondsTimer), userInfo: nil, repeats: true)
        
        //self.findNearestResturantsForSquareApi(name:"lunch")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
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
                guard let data = URLSession.shared.query(address: str) else {return}
                if let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    //                    print(String(data: data!, encoding: .utf8)!)
                    let sentiment =  dict!.value(forKey: "sentiment") as! String
                    //let confidence = dict!.value(forKey: "confidence") as! String
                    
                    finalData.append(Details(resturantName: items.resturantName, resturantRating: items.resturantRating, totalRating:items.totalRating, reviewsText: "\(items.reviewsText + "  sentiment: \(sentiment)")", photoLink:items.photoLink))
                    //print(finalData)
                    //self.textVew.text = "\(finalData)"
                    //print(finalData)
                    DispatchQueue.main.async {
                        
                        
                        do {
                            let encoder = JSONEncoder()
                            encoder.outputFormatting = .prettyPrinted
                            let data = try encoder.encode(finalData)
                            let final  = (String(data: data, encoding: .utf8)!)
                            //print(final)
                            //self.textVew.text = "\(final)"
                            
                        } catch let error {
                            print("error converting to json: \(error)")
                            
                        }
                    }
                }
            }
        }
    }
   var resturantNamesArray = [String]()
    var logoImages = [String]()
    func combineData(location:CLLocation, completetion: @escaping ([Details])->Void){
        
        var dataArray:[Details] = []
        var dataArray1:[Details] = []
        guard let searchText = searchTextField.text else {return}
        DispatchQueue.global(qos: .background).async {
            
            dataArray = self.findNearestResturantsForSquareApi(name:searchText)
            //print(dataArray)
            dataArray1 = self.findNearestResturantsByGooglePlaces(coord: (location.coordinate))
            
            dataArray.append(contentsOf: dataArray1)
            print(dataArray)
            completetion(dataArray)
            
            
            
            
            for i in dataArray {
                self.resturantNamesArray.append(i.resturantName)
                self.logoImages.append(i.photoLink)
                
                
                DispatchQueue.main.async {
                    
                   self.tableView.reloadData()
                }
                
                
                //print(i.resturantName)
            }
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
    
    
    func findNearestResturantsForSquareApi(name:String) -> [Details] {
        
        var fName:String = ""
        var fRatingz:Double = 0.0
        var fTotalRatings:Int = 0
        var fReviewText:String = ""
        var fPhoto:String = ""
        var coordn = CLLocationCoordinate2D()
        coordn.latitude =  CLLocationDegrees(exactly: 24.770837)!
        coordn.longitude = CLLocationDegrees(exactly:46.679192)!
        
        
        let url = "https://api.foursquare.com/v2/search/recommendations?ll=\(coordn.latitude),\(coordn.longitude)&section=food&v=20160607&intent=\(name)&limit=20&client_id=ZMSMIQAE0PIKGYAUHBM4IMSFFQA4WXEZNG5FYUHGBABFPE3C&client_secret=KYOC41BAQCFKGM5FN0SUASNR5JAK1B4KMR204M3CEPQEL4GO&oauth_token=NKRP0KY5ZDZIBMCU3TZS4BMP4ZMIQZBQPLBTCPXSIGPWFJ1L"
        
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
        return resturantDetails;
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
        
        if searchTextField.text != "" {
           
            //start the location service
            locationManager.startUpdatingLocation()
            
        }else {
            
        }
        
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
        
        return resturantNamesArray.count
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RestDetailsCell
        //cell.configureCell(resturant: filtereRes[indexPath.row])
        cell.resturantName.text = resturantNamesArray[indexPath.row]
        cell.restBGImage.sd_setImage(with: URL(string: logoImages[indexPath.row]), placeholderImage: UIImage(named: "wao.png"))
        return cell
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
