//
//  ResturantDetailsTableViewController.swift
//  VibeApp
//
//  Created by Yazeedo on 26/03/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import ParallaxHeader
import SnapKit
import SVProgressHUD
import MapKit
class ResturantDetailsTableViewController: UITableViewController, MKMapViewDelegate {
    
    var resturant:Details!
    weak var headerImageView: UIView?
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var resturantNameLabel: UILabel!
    @IBOutlet weak var resturantTypeLabel: UILabel!
    @IBOutlet weak var FeelingLAbel: UILabel!
    @IBOutlet weak var feelingPercentage: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var chickInNumberLabel: UILabel!
    @IBOutlet weak var resturantReview: UITextView!
    @IBOutlet weak var openingHourLabel: UILabel!
    var haveOpeningHour = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderImage()
         self.updateContents()
        DispatchQueue.global(qos: .background).async {
        self.getHour {
            DispatchQueue.main.async {
                self.UpdateOpeningHour()
            }
        }
        }
        
        var annotations = [MKPointAnnotation]()
        let lat = CLLocationDegrees(resturant.langtitude)
        let long = CLLocationDegrees(resturant.longtitude)
        
         let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = resturant.resturantName
//        annotation.subtitle = mediaURL
        annotations.append(annotation)
        self.map.addAnnotations(annotations)
        
        
        let latitude:CLLocationDegrees = resturant.langtitude
        
        let longitude:CLLocationDegrees = resturant.longtitude
        
        let latDelta:CLLocationDegrees = 0.05
        
        let lonDelta:CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: false)
    }
    
    func updateContents() {
        resturantNameLabel.text = resturant.resturantName
        resturantTypeLabel.text = resturant.resturantType
        
        switch resturant.feeling {
        case "منبهر":
            FeelingLAbel.text = "\(resturant.feeling!) 😍"
        case "سعيد":
            FeelingLAbel.text = "\(resturant.feeling!) 😂"
        case "مريح":
            FeelingLAbel.text = "\(resturant.feeling!) 😌"
        case "نادم":
            FeelingLAbel.text = "\(resturant.feeling!) 🙁"
        case "حزين":
            FeelingLAbel.text = "\(resturant.feeling!) 😢"
        case "غاضب":
            FeelingLAbel.text = "\(resturant.feeling!) 😡"
        default:
            FeelingLAbel.text = "\(resturant.feeling!) 😐"
            break
        }
        feelingPercentage.text = "\(resturant.feelingRating)%"
        priceLabel.text = NSLocalizedString(resturant.currency, comment: "")
        chickInNumberLabel.text = String(resturant.checkInCount)
        resturantReview.text = resturant.reviewsText
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
    }
    
    func UpdateOpeningHour() {
        if let resturantStartDate = resturant.startHours {
            
            if resturantStartDate != "" {
              openingHourLabel.text = getTimeFormat()
            }else{
                openingHourLabel.text = "لا يوجد"
            }
        }
    }
    func setupHeaderImage() {
        
        
        let imageView = UIImageView()
        imageView.image = resturant.photo!
        imageView.contentMode = .scaleAspectFit
        
        //setup blur vibrant view
        imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()
        
        // headerImageView = imageView
        
        tableView.parallaxHeader.view = imageView
        tableView.parallaxHeader.height =  176
        tableView.parallaxHeader.minimumHeight = 150
        tableView.parallaxHeader.mode = .bottom
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            //update alpha of blur view on top of image view
            parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
        }
        
        // Label for vibrant text
        let vibrantLabel = UILabel()
        vibrantLabel.numberOfLines = 0
        vibrantLabel.text = "\n\n\(resturant.resturantName)"
        vibrantLabel.font = UIFont.systemFont(ofSize: 35.0)
        vibrantLabel.sizeToFit()
        vibrantLabel.textAlignment = .center
        imageView.blurView.vibrancyContentView?.addSubview(vibrantLabel)
        //add constraints using SnapKit library
        vibrantLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func getHour(completion: ()-> Void) {
        
        var fStartHour = ""
        var fEndHour = ""
        
        let hourData = URLSession.shared.query(address: "https://api.foursquare.com/v2/venues/\(resturant.resturantId)/hours?v=20160607&client_id=ZMSMIQAE0PIKGYAUHBM4IMSFFQA4WXEZNG5FYUHGBABFPE3C&client_secret=KYOC41BAQCFKGM5FN0SUASNR5JAK1B4KMR204M3CEPQEL4GO&oauth_token=NKRP0KY5ZDZIBMCU3TZS4BMP4ZMIQZBQPLBTCPXSIGPWFJ1L")
        
        if let HourjsonDict = try? JSONSerialization.jsonObject(with: hourData!, options: .allowFragments) as? NSDictionary {
            
            if let response = HourjsonDict!.value(forKey: "response") as? NSDictionary {
                
                
                if let hours = response.value(forKey: "hours") as? NSDictionary {
                    
                    if let timeFrame = hours.value(forKey: "timeframes") as? NSArray {
                        if let frame = timeFrame[0] as? NSDictionary{
                            if let open = frame.value(forKey: "open") as? NSArray{
                                
                                
                                
                                if let finalHour = open[0] as? NSDictionary {
                                    if let start = finalHour.value(forKey: "start") as? String{
                                        
                                        fStartHour = start
                                    }
                                    if let end = finalHour.value(forKey: "end") as? String{
                                        
                                        fEndHour = end
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
        
        if fStartHour != "" {
            resturant.startHours = fStartHour
        }
        if fEndHour != "" {
            resturant.EndHours = fEndHour
        }
        
        completion()
        
    }
    
    func getTimeFormat() -> String {
    
        var startHours = resturant.startHours!
        var endHours = resturant.EndHours!
        
        if startHours.first == "+" {
            startHours.removeFirst()
        }
        if endHours.first == "+" {
            endHours.removeFirst()
        }
        
        startHours.insert(":", at: startHours.index(startHours.startIndex, offsetBy: 2))
        endHours.insert(":", at: endHours.index(endHours.startIndex, offsetBy: 2))
    
        return "\(startHours) - \(endHours)"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 3 && indexPath.row == 1 {
            
            
            UIApplication.shared.open(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(resturant.langtitude),\(resturant.longtitude)&directionsmode=driving")! as URL, options: [:], completionHandler: nil)
    
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
