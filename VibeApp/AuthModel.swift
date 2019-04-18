
import Foundation
import FirebaseAuth
import FirebaseDatabase
import Firebase
class AuthModel {
    
    
    static func singIn(email : String , password : String, onSuccess : @escaping ()-> Void , onError : @escaping (_ ErrorDescription: String)-> Void ) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                onError((error?.localizedDescription)!)
                return
            }
        onSuccess()
        }
    }
    
    
    static func signUP( username : String , imageData : Data ,  email : String , password : String, onSuccess : @escaping ()-> Void , onError : @escaping (_ ErrorDescription: String)-> Void ) {
      
        Auth.auth().createUser(withEmail:email, password: password) { (user, error) in
            if error != nil {
                onError((error?.localizedDescription)!)
                return
            }
            
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }
            
            let storageRef : StorageReference!
            storageRef = Storage.storage().reference(forURL: "gs://vibeapp01.appspot.com").child("Users")
           
                storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                    if error != nil {
                        onError((error?.localizedDescription)!)
                        return
                    }
                    storageRef.downloadURL(completion: { (url : URL?, error : Error?) in
                        let profileImge = url?.absoluteString
                        
                        setUserInformationToDatabase(profileImage: profileImge!, email: email, userName: username)
                        onSuccess()
                        
                    })
                })
                
                func setUserInformationToDatabase (profileImage : String , email : String , userName : String) {
                    let ref : DatabaseReference!
                    ref = Database.database().reference()
                    let userRefrance = ref.child("Users")
                    let newUserRef = userRefrance.child(userID)
                    newUserRef.setValue(["profileImge" : profileImage ,  "email" : email , "userName" : userName])
                  onSuccess()
                    
                    
                }
            
            
            
            
            
        }
        
        
        
    }
    
    
}
