//
//  ResturantDetailsTableViewController.swift
//  VibeApp
//
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import ParallaxHeader
import SnapKit
import SVProgressHUD
import MapKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
import FirebaseAuth
class ResturantDetailsTableViewController: UITableViewController, MKMapViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resturantImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! restImageCell
        cell.configureUI(image: resturantImage[indexPath.row])
        return cell
    }
    
    
    
    var resturant:Details!
    var resturantImage = [UIImage]()
    var imagesURLlist = [String]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var headerImageView: UIView?
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var resturantNameLabel: UILabel!
    @IBOutlet weak var resturantTypeLabel: UILabel!
    @IBOutlet weak var FeelingLAbel: UILabel!
    @IBOutlet weak var feelingPercentage: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var chickInNumberLabel: UILabel!
    @IBOutlet weak var resturantReview: UITextView!
    @IBOutlet weak var openingHourLabel: UILabel!
    @IBOutlet weak var phoneCell: UITableViewCell!
    var isLiked = false
    var LikeButton: UIBarButtonItem!
    
    
    var haveOpeningHour = false
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let photo = resturant.photo {
            resturantImage.append(photo)
        }
        
        
        if Auth.auth().currentUser != nil {
            LikeButton = UIBarButtonItem(title: "إعجاب", style: .plain, target: self, action: #selector(likeResturant))
            navigationItem.rightBarButtonItem = LikeButton
            configureLikedResturant()
        }
        
        print(resturant.resturantId)
        setupHeaderImage()
        self.updateContents()
        DispatchQueue.global(qos: .background).async {
            self.getHour {
                DispatchQueue.main.async {
                    self.UpdateOpeningHour()
                }
            }
        }
        
        SVProgressHUD.show()
        
        getImagesURL {
            self.FillArrayImage {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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
        resturantReview.text = resturant.reviewsText[0]
        
        if let phoneNumber = resturant.contactNumber {
            if phoneNumber != "" {
                phoneNumberLabel.text = phoneNumber
                phoneCell.selectionStyle = .default
            }else {
                phoneNumberLabel.text = "لايوجد"
                phoneCell.selectionStyle = .none
            }
        }
        
    }
    
    func configureLikedResturant() {
        isLiked = LikedResturant.shared.resturantList.contains { (details) -> Bool in
            details.resturantId == resturant.resturantId
        }
        
        if isLiked {
            LikeButton.title = "إزالة الإعجاب"
        }else{
            LikeButton.title = "إعجاب"
        }
    }
    
    
    @objc func likeResturant() {
        let userID = Auth.auth().currentUser?.uid
        
        if isLiked {
            DataService.instance.REF_Users.child(userID!).child("Likes").child(resturant.resturantId).removeValue()
            LikedResturant.shared.resturantList = LikedResturant.shared.resturantList.filter{$0.resturantId != resturant.resturantId}
        }else{
            LikedResturant.shared.resturantList.append(resturant)
            DataService.instance.REF_Users.child(userID!).child("Likes").child(resturant.resturantId).setValue(resturant.resturantId)
        }
        
        isLiked = !isLiked
        configureLikedResturant()
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
        
        //        5318232d498e6841bd3d878b
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
        
        if indexPath.section == 2 && indexPath.row == 1 {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "اختيار صورة", style: .default, handler: { (action:UIAlertAction) in
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "التقاط صورة", style: .default, handler: { (action:UIAlertAction) in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "إلغاء", style: .cancel, handler: nil))
            
            self.present(actionSheet, animated: true, completion: nil)
        }
        if indexPath.section == 4 && indexPath.row == 1 {
            
            
            UIApplication.shared.open(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(resturant.langtitude),\(resturant.longtitude)&directionsmode=driving")! as URL, options: [:], completionHandler: nil)
            
            
            
        }
        
        if indexPath.section == 5 && indexPath.row == 0 && phoneNumberLabel.text != "لايوجد"{
            if let url = URL(string: "tel://\(phoneNumberLabel.text!)"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                // add error message here
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 2 && indexPath.row == 1 {
            if Auth.auth().currentUser == nil {
                cell.isHidden = true
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            if Auth.auth().currentUser == nil {
               return 0
            }else{
                 return super.tableView(tableView, heightForRowAt: indexPath)
            }
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            SVProgressHUD.show()
            uploadImage(num: 0, image: image) {
                 self.resturantImage.append(image)
                self.collectionView.reloadData()
                SVProgressHUD.dismiss()
            }
           
            
        }
        imagePickerControllerDidCancel(picker)
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            originalImage.image = image
//            configureNavigationBarItems()
//            imagePickerControllerDidCancel(picker)
//
//        }
//    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRate"{
            let ratingVC = segue.destination as! RatingViewController
            
            ratingVC.resturantRating = resturant.tweetRating
        }else if segue.identifier == "commentSegue" {
            let commentVC = segue.destination as! CommentsTableViewController
            commentVC.resturant = resturant
        }else if segue.identifier == "imagePreivew" {
            let previewrVC = segue.destination as! ImagePreviewerVC
            let indexPaths : NSArray = collectionView.indexPathsForSelectedItems! as NSArray
            let indexx : IndexPath = indexPaths[0] as! IndexPath
            previewrVC.resturantImage = resturantImage[indexx.row]
        }
    }
    
    
    
    
    func uploadImage(num:Int,image: UIImage, completion: @escaping () -> Void){
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        let randomId = DataService.instance.REF_Users.childByAutoId().key
        // Create a storage reference from our storage service
        let storageRef = storage.reference().child("Resturant").child(resturant.resturantId).child("Image").child(randomId!)
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.25) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
 
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL(completion: { (url : URL?, error : Error?) in
                    let profileImge = url?.absoluteString
                    DataService.instance.REF_Resturant.child(self.resturant.resturantId).child("Images").childByAutoId().setValue(profileImge!)
                    completion()
                })
                    
               
                
            } else {
                completion()
            }
    }
}
    
    
    
    func getImagesURL(completion: @escaping () -> Void) {
        
        DataService.instance.REF_Resturant.child(resturant.resturantId).child("Images").observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
            return}
            
            if snapshot.count > 0 {
                for url in snapshot {
                    if let item = url.value as? String{
                        self.imagesURLlist.append(item)
                    }
                }
              completion()
            }else {
                SVProgressHUD.dismiss()
                completion()
            }
        }

    }
        
    func FillArrayImage(completion: @escaping () -> Void) {
        
        
        for url in imagesURLlist {
           
            
            let request = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                
                if error == nil{
                    
                    guard let data = data else {
                        return
                    }
                    if let image = UIImage(data: data) {
                        self.resturantImage.append(image)
                        if self.resturantImage.count - 1 == self.imagesURLlist.count {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                SVProgressHUD.dismiss()
                            }
                        }
                    }
                    
                    
                    
                }else {
                     SVProgressHUD.dismiss()
                }
            }
            
            request.resume()
        }
        
       completion()
        
    }
}
