//
//  WelcomeViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 2/6/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            loginUser()
            
        } else {
            
            ProgressHUD.showError("Email or Password is missing!")
            
        }
    }
    
    @IBAction func backgrounTap(_ sender: Any) {
        
        dismissKeyboard()
    }
    
    //MARK: HelperFunctions
    
    func loginUser() {
        
        ProgressHUD.show("Loging You In...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error != nil {
                
                // if there is an error show the error to us
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            // if no error then present the app
            self.goToApp()
        }
        
    }
    
    func dismissKeyboard() {
        // dismisses keyboard
        self.view.endEditing(false)
    }
    
    // gets rid of any text in textFields
    func cleanTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    //MARK: GoToApp
    
    func goToApp() {
        
        
        // clear progress message
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }

}














