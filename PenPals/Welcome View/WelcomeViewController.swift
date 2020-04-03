//
//  WelcomeViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 2/6/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//
//imports
import UIKit
import ProgressHUD
import JGProgressHUD
import Firebase

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let hud = JGProgressHUD(style: .light)
    
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
            hud.textLabel.text = "Email or Password is missing!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.0)
            
            
        }
    }
    
    @IBAction func backgrounTap(_ sender: Any) {
        
        dismissKeyboard()
    }
    
    //MARK: HelperFunctions
    
    func hud1() {
        hud.textLabel.text = "Loging You In...."
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2.0)
    }
    
    func hud2() {
        hud.textLabel.text = "Success"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.dismiss(afterDelay: 1.0)
    }
    
    func loginUser() {
        
        ProgressHUD.show("Loging You In...")
        
        
        hud1()
        hud2()

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














