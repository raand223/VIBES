//
//  CameraVC.swift
//  VibeApp
//
//  Created by MacBook Pro on 15/02/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase


class CameraVC: UIViewController {
    
    @IBOutlet weak var camerOutLet: UIImageView!
    @IBOutlet weak var captionLabel: UITextView!
    
    var selectedPostToDatabase : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture  = UITapGestureRecognizer(target: self, action: #selector(SingUpVC.handelSelectedImage))
        camerOutLet.addGestureRecognizer(tapGesture)
        camerOutLet.isUserInteractionEnabled = true
        
 
    }
    

    @objc func handelSelectedImage() {
        let pickImage = UIImagePickerController()
        pickImage.delegate = self
        present(pickImage, animated: true, completion: nil)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        if let userselectePost = self.selectedPostToDatabase , let imageData = UIImageJPEGRepresentation(userselectePost, 0.1) {
            
            let postID = NSUUID().uuidString
            let storageRef : StorageReference!
            storageRef = Storage.storage().reference(forURL: "gs://vibeapp01.appspot.com").child("Users").child(postID)
            
            storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                    print((error?.localizedDescription)!)
                    return
                }
                
                storageRef.downloadURL(completion: { (url : URL?, error : Error?) in
                    let postImageURL = url?.absoluteString
                    sendPostToDatabase(postImageURL: postImageURL!, caption: self.captionLabel.text)
                })
            })
            
            func sendPostToDatabase(postImageURL : String , caption : String) {
                guard let userIdPost = Auth.auth().currentUser?.uid else { return}
                let ref : DatabaseReference!
                ref = Database.database().reference()
                let PostRef = ref.child("Posts")
                let postID = PostRef.childByAutoId().key
                let newPostRef = PostRef.child(postID!)
                newPostRef.setValue([ "userId" : userIdPost ,"postURL" : postImageURL, "caption" : caption]) { (error, ref) in
                    if error != nil {
                        return
                    }
                    
                    self.tabBarController?.selectedIndex = 0
                    clear()
                }
            }
        }
        
        func clear() {
            captionLabel.text = ""
            camerOutLet.image = UIImage(named: "PostImage")
        }
        
    }
}
extension CameraVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userSelectImageFromLibrary = info [UIImagePickerControllerOriginalImage] as? UIImage {
            camerOutLet.image = userSelectImageFromLibrary
            selectedPostToDatabase = userSelectImageFromLibrary
            dismiss(animated: true, completion: nil)
        }
    }
}
