//
//  RegisterViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 2/7/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            
            //validates both passwords match
            if passwordTextField.text == confirmPasswordTextField.text {
                
                registerUser()

            } else {
                
                ProgressHUD.showError("Passwords Don't Match!")
            }
            
            
            
        } else {
            
            ProgressHUD.showError("All Field are Required!")
            
        }
    }
    
    @IBAction func baskgroundTapped(_ sender: Any) {
        print("dismiss")
    }
    
    
    //MARK: Helper Functions
    
    func registerUser() {
        
        performSegue(withIdentifier: "registerToFinishRegistration", sender: self)

        cleanTextFields()
        dismissKeyboard()
                
    }
    
    func dismissKeyboard() {
        // dismisses keyboard
        self.view.endEditing(false)
    }
    
    // gets rid of any text in textFields
    func cleanTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
        usernameTextField.text = ""
    }
    
    //MARK: GoToApp
    
    func goToApp() {
        
        // clear progress message
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        self.present(mainView, animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "registerToFinishRegistration" {
            
            let vc = segue.destination as! FinishRegistrationViewController
            vc.email = emailTextField.text!
            vc.password = passwordTextField.text!
        }
    }
}
