//
//  CommentsTableViewController.swift
//  VibeApp
//
//  Created by Yazeedo on 05/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import FirebaseAuth
class CommentsTableViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet weak var sendView: UIView!
    
    var resturant:Details!
    var commentsList: [String] = [String]()
    @IBOutlet weak var commentTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "التعليقات"
        commentTextField.delegate = self
        commentsList.append(resturant.reviewsText[0])
        SVProgressHUD.show()
        getComment()
        
         if Auth.auth().currentUser != nil {
            sendView.isHidden = false
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = commentsList[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    

    @IBAction func sendCommentTapped(_ sender: Any) {
        DataService.instance.REF_Resturant.child(resturant.resturantId).child("Comments").childByAutoId().setValue(commentTextField.text ?? "حلو")
        commentTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getComment() {
       DataService.instance.REF_Resturant.child(resturant.resturantId).child("Comments").observe(.value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
               SVProgressHUD.dismiss()
                return }
            
            if snapshot.count > 0 {
                self.commentsList.removeAll()
                 self.commentsList.append(self.resturant.reviewsText[0])
                for comment in snapshot {
                    if let item = comment.value as? String{
                        self.commentsList.append(item)
                    }
                }
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        
        }
        
        if commentsList.count == 1 {
            SVProgressHUD.dismiss()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
}
