

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SVProgressHUD


class SingUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var singUpBB: UIButton!
    @IBOutlet weak var profileImageOutLet: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var selectedImageToDatabase : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 335, height: 0.6)
        bottomLayerEmail.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        emailTextField.layer.addSublayer(bottomLayerEmail)
        let bottomLayerPassWord = CALayer()
        bottomLayerPassWord.frame = CGRect(x: 0, y: 29, width: 335, height: 0.6)
        bottomLayerPassWord.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        passwordTextField.layer.addSublayer(bottomLayerPassWord)
        
        let bottomLayerUserName = CALayer()
        bottomLayerUserName.frame = CGRect(x: 0, y: 29, width: 335, height: 0.6)
        bottomLayerUserName.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        usernameTextField.layer.addSublayer(bottomLayerUserName)
        
        usertapOnTextFields()
        singUpBB.isEnabled = false
        
        let tapGesture  = UITapGestureRecognizer(target: self, action: #selector(SingUpVC.handelSelectedImage))
        profileImageOutLet.addGestureRecognizer(tapGesture)
        profileImageOutLet.isUserInteractionEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        textField.resignFirstResponder()
        return true
    }
    
    @objc func usertapOnTextFields() {
        emailTextField.addTarget(self, action: #selector(SingInVC.userTapNameAndPassWord), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SingInVC.userTapNameAndPassWord), for: UIControlEvents.editingChanged)
        usernameTextField.addTarget(self, action: #selector(SingInVC.userTapNameAndPassWord), for: UIControlEvents.editingChanged)
    }
    
    @objc func userTapNameAndPassWord() {
        guard let email = emailTextField.text , !email.isEmpty , let passWord = passwordTextField.text , !passWord.isEmpty , let user = usernameTextField.text , !user.isEmpty else {
            singUpBB.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.5803921569, blue: 0.5843137255, alpha: 1)
            singUpBB.isEnabled = false
            return
        }
        
        singUpBB.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.5803921569, blue: 0.5843137255, alpha: 1)
        singUpBB.isEnabled = true
    }
    
    @objc func handelSelectedImage() {
        let pickImage = UIImagePickerController()
        pickImage.delegate = self
        present(pickImage, animated: true, completion: nil)
    }
    
    @IBAction func dismissToSingInVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func singUpButton(_ sender: Any) {
        if let userSelectedImage = self.selectedImageToDatabase , let imageData = UIImageJPEGRepresentation(userSelectedImage, 0.1) {
            SVProgressHUD.show(withStatus: "إنتظر ...")
            AuthModel.signUP(username: usernameTextField.text!, imageData: imageData, email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
                SVProgressHUD.showSuccess(withStatus: "أهلا بك ")
                self.performSegue(withIdentifier: "singUpToTab", sender: nil)
            }, onError: {errorMessage in
                
                SVProgressHUD.showError(withStatus: "تأكد من بياناتك")
            })
        }
    }
}


extension SingUpVC : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userSelectImageFromLibrary = info [UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageOutLet.image = userSelectImageFromLibrary
            selectedImageToDatabase = userSelectImageFromLibrary
            dismiss(animated: true, completion: nil)
        }
    }
}
