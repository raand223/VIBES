

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import SDWebImage

class ProfileVC: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var b: UIButton!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBAction func b(_ sender: Any) {
        let prompt = UIAlertController(title: "VIBES", message: "البريد الإلكتروني:", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "إرسال", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            Auth.auth().sendPasswordReset(withEmail: userInput!, completion: { (error) in
                if let error = error {
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        ///
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        self.showAlert("ستتلقى بريدًا إلكترونيًا لإعادة تعيين كلمة المرور الخاصة بك.")
                    }
                }
            })
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        email.delegate = self
        let bottomLayeremail = CALayer()
        bottomLayeremail.frame = CGRect(x: 0, y: 29, width: 335, height: 0.6)
        bottomLayeremail.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        email.layer.addSublayer(bottomLayeremail)
        
        let bottomLayerUserName = CALayer()
        bottomLayerUserName.frame = CGRect(x: 0, y: 29, width: 335, height: 0.6)
        bottomLayerUserName.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        userName.layer.addSublayer(bottomLayerUserName)
        email.text = Auth.auth().currentUser?.email
        
        let databaseRef = Database.database().reference()
        
        if let uid = Auth.auth().currentUser?.uid{
            databaseRef.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject]
                {
                    self.userName.text = dict["userName"] as? String
                    //
                    //                    let imageName = NSUUID().uuidString
                    //
                    //                    let storedImage = databaseRef.child("profileImge").child(imageName)
                    
                    
                    //
                    //
                }
            })
            
        }
        
    
        
    }
    
    
    
    
    @IBAction func changebutton(_ sender: Any) {
        let userEmail = Auth.auth().currentUser
        
        userEmail?.updateEmail(to: email.text!, completion: { (error) in
            if error != nil {
                
                SVProgressHUD.showError(withStatus: "حاول مره أخرى")
                
            }
            let ref : DatabaseReference
            ref = Database.database().reference()
            let userID = Auth.auth().currentUser?.uid
            let user = ref.child("Users").child(userID!)
            let userEmail = user.child("email")
            userEmail.setValue(self.email.text!)
            
            
            
        })
        
        let username = Auth.auth().currentUser?.createProfileChangeRequest()
        username?.displayName = userName.text!
        username?.commitChanges(completion: { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "حاول مره أخرى")
            }
            let ref : DatabaseReference
            ref = Database.database().reference()
            let userID = Auth.auth().currentUser?.uid
            let user = ref.child("Users").child(userID!)
            let usernameChange = user.child("userName")
            usernameChange.setValue(self.userName.text!)
            
        })
    }
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "To Do App", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logOutError {
            print(logOutError)
        }
        print("usser try to log out")
        
        let storayBoard = UIStoryboard(name: "Start", bundle: nil)
        LikedResturant.shared.resturantList.removeAll()
        self.dismiss(animated: false, completion: nil)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}





