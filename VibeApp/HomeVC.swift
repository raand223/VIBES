//
//  HomeVC.swift
//  VibeApp
//
//  Created by MacBook Pro on 15/02/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import SDWebImage

class HomeVC: UIViewController {
    
    var postContinerArray = [PostModel]()
    @IBOutlet weak var tableViewOutLet: UITableView!
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        tableViewOutLet.estimatedRowHeight = 585
        tableViewOutLet.rowHeight = UITableViewAutomaticDimension
        
        observePostFromDatabase()
    }
    
    
    
    @objc func observePostFromDatabase() {
        Database.database().reference().child("Posts").observe(.childAdded) { (snapshot : DataSnapshot) in
            if let dic = snapshot.value as? [String : Any] {
                let post = PostModel(key: snapshot.key, dic: dic)
                self.postContinerArray.insert(post, at: 0) // show recent posts first
                self.tableViewOutLet.reloadData()
            }
        }
        
        // observe removed childs and delete them from models array and tableView
        Database.database().reference().child("Posts").observe(.childRemoved) { (snapshot : DataSnapshot) in
            if let post = self.postContinerArray.first(where: { $0.key == snapshot.key }), let index = self.postContinerArray.index(of: post) {
                self.postContinerArray.remove(at: index)
                self.tableViewOutLet.beginUpdates()
                self.tableViewOutLet.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .automatic)
                self.tableViewOutLet.endUpdates()
            }
        }
    }
    
    
}

extension HomeVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postContinerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PoastCell") as! HomeCell
        
        let postModelContent = postContinerArray[indexPath.row]
        cell.postC = postModelContent
        cell.selectionStyle = .none
        
        return cell
    }
}

extension HomeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        let postModelContent = postContinerArray[indexPath.row]
        
        // check if current user is the owner for the post & enable delete button only for him
        return postModelContent.userPostId == userId
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let postModelContent = postContinerArray[indexPath.row]
        
        if editingStyle == .delete {
            print("deleting: ", postModelContent.key)
            deletePost(WithKey: postModelContent.key)
        }
    }
    
    // delete from realtime database
    private func deletePost(WithKey key: String) {
        Database.database().reference().child("Posts").child(key).removeValue()
    }
    
}
