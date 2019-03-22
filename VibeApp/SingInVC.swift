//
//  SingInVC.swift
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


class SingInVC: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var singInBB: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        emailTextField.delegate = self

        
        
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 335, height: 0.6)
        bottomLayerEmail.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        let bottomLayerPassWord = CALayer()
        bottomLayerPassWord.frame = CGRect(x: 0, y: 29, width: 335, height: 0.6)
        bottomLayerPassWord.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        passwordTextField.layer.addSublayer(bottomLayerPassWord)
        
        usertapOnTextFields()
        singInBB.isEnabled = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        textField.resignFirstResponder()
        return true
    }
    
    @objc func usertapOnTextFields () {
        emailTextField.addTarget(self, action: #selector(SingInVC.userTapNameAndPassWord), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SingInVC.userTapNameAndPassWord), for: UIControlEvents.editingChanged)
    }
    
    @objc func userTapNameAndPassWord () {
        guard let email = emailTextField.text , !email.isEmpty , let passWord = passwordTextField.text , !passWord.isEmpty else {
            singInBB.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.5803921569, blue: 0.5843137255, alpha: 1)
            singInBB.isEnabled = false
            return
        }
        singInBB.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.5803921569, blue: 0.5843137255, alpha: 1)
        singInBB.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func singInButton(_ sender: Any) {
        SVProgressHUD.show(withStatus: "جاري تسجيل دخولك")
        AuthModel.singIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            SVProgressHUD.showSuccess(withStatus: "مرحبا بـك")
            self.performSegue(withIdentifier: "singIntaBar", sender: nil)
        }, onError: {errorDescription in
            let errorDescription = "تأكد من بياناتك"
            SVProgressHUD.showError(withStatus: errorDescription)
        })
    }
    
}
