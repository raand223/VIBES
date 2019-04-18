
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import SVProgressHUD
class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3){
            if Auth.auth().currentUser != nil {
                self.performSegue(withIdentifier: "alreadySignIn", sender: nil)
            }else{
                self.performSegue(withIdentifier:"SingIn", sender:nil)
            }
        }
    }

}
