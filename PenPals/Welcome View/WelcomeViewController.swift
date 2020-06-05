//
//  WelcomeViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/6/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//
//imports
import UIKit
import JGProgressHUD
import Firebase

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.borderWidth = 2
        
        let myBorderColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        
        signUpButton.layer.borderColor = UIColor.lightGray.cgColor
        //signUpButton.layer.borderColor = myBorderColor.cgColor

        
    }
    
    //MARK: IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            loginUser()
            
        } else {
            
            hud.textLabel.text = "Email or Password is missing!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.5)
        }
    }
    
    @IBAction func backgrounTap(_ sender: Any) {
        
        dismissKeyboard()
    }
    
    //MARK: HelperFunctions
    
    func loginUser() {
        
        hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loggin you in..."
        hud.show(in: self.view)

        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error != nil {
                
                // if there is an error show the error to us
                self.hud.textLabel.text = "\(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 1.5)
                
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
        
        hud.dismiss()
        hud.textLabel.text = "Sucess!"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.dismiss()
        
        cleanTextFields()
        dismissKeyboard()
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }

}














