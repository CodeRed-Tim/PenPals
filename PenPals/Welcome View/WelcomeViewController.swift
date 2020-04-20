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
    
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    let hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.borderWidth = 2
        
        let myGrayColor = UIColor(red: 0.22, green: 0.33, blue: 0.53, alpha: 1.0 )
        signUpButton.layer.borderColor = myGrayColor.cgColor

        
    }
    
    //MARK: IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        dismissKeyboard()
        
        detectlanguage()
        initiateTranslation()
        
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
    
    //change to this 'text' variable after testing
    var text = "hello"
    
    // this will get the language code
    //for example if text="Good morning" it will get en
    func detectlanguage() {
        
        TranslationManager.shared.detectLanguage(forText: text) { (language) in
            
            if let language = language {
                print("The detected language was \(language)")
            } else {
                print("Oops! It seems that something went wrong and language cannot be detected.... detetcLanguage()")
            }
            
        }
    }
    
    func checkForLanguagesExistence() {
        // Check if supported languages have been fetched by looking at the
        // number of items in the supported languages collection of the
        // TranslationManager shared instance.
        // If it's zero, no languages have been fetched, so ask user
        // if they want to fetch them now.
        fetchSupportedLanguages()
        print("checkForLanguagesExistence()")
    }
    
    func fetchSupportedLanguages() {
        
        var getLanguages = true
        
        TranslationManager.shared.fetchSupportedLanguages { (success) in
            
            if success {
                //run the translation method
                getLanguages = true
                print("got the supported languages... getLanguages()")
            } else {
                //error
                getLanguages = false
                print("didn't get the supported languages... getLanguages()")
            }
            
        }
        
    }
    
    func translate() {
//        checkForLanguagesExistence()
        getTargetLangCode()
        TranslationManager.shared.textToTranslate = text
        print("translate(\(text))")
    }
    
    func getTargetLangCode() {
        
        TranslationManager.shared.targetLanguageCode = "fr"
        print("getTargetLanguage()")
    }
    
    func initiateTranslation() {
        
        translate()
        
        TranslationManager.shared.translate { (translation) in
            
            if let translation = translation {
                
                self.text = translation
                print(self.text)
            } else {
                print("Oops! It seems that something went wrong and translation cannot be done... initiateTranslation()")
            }
            
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














