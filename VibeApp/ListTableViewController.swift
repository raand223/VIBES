//
//  ListTableViewController.swift
//  VibeApp
//
//  Created by Shahad Aldkhaiel on 21/06/1440 AH.
//  Copyright © 1440 MacBook Pro. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
class ListTableViewController: UIViewController {
    
    @IBOutlet weak var ResName: UILabel!
    
    @IBOutlet weak var ResLocation: UILabel!
    
    @IBOutlet var ListTableView: UITableView!
    
    var ref: DatabaseReference?
    var ResFavList = [ListModel]()
    var likedResturanta = [Details]()
    var keyArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ListTableView.dataSource = self
//        loadList()
        getLikesResturant()
        ref = Database.database().reference()
        
    }
    
    func loadList(){
        Database.database().reference().child("favoriteList").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                let userIdText = dict["userId"] as! String
                let restaurantNameText = dict["resturantName"] as! String
                let resturantLocationText = dict["resturantLocation"] as! String
                let favRestaurant = ListModel(userIdText: userIdText, restaurantNameText: restaurantNameText, resturantLocationText: resturantLocationText)
                self.ResFavList.append(favRestaurant)
                print(self.ResFavList)
                self.ListTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if  editingStyle == .delete {
            getAllKeys()
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                self.ref?.child("favoriteList").child(self.keyArray[indexPath.row]).removeValue()
                self.ResFavList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.keyArray = []
                
            })
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func getAllKeys(){
        ref?.child("favoriteList").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                self.keyArray.append(key)
                
            }
        })
    }
    
    func getLikesResturant(){
        let userID = Auth.auth().currentUser?.uid
        DataService.instance.REF_Users.child(userID!).child("Likes").childByAutoId().setValue("506a9744e4b05499f5d3309d")
    }
}
extension ListTableViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ResFavList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResCell", for: indexPath)
        cell.textLabel?.text = ResFavList[indexPath.row].resturantName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

let db_base = Database.database().reference()
class DataService {
    
    static  let  instance = DataService()
    var REF_Resturant = db_base.child("Resturant")
    var REF_Users = db_base.child("Users")
}

class LikedResturant {
    static let shared = LikedResturant()
    var resturantList = [Details]()
}
