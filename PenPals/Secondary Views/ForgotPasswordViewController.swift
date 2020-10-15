//
//  ForgotPasswordViewController.swift
//  PenPals
//
//  Created by MaseratiTim on 10/14/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JGProgressHUD
import Firebase

class ForgotPasswordViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var languagePicker: UIPickerView!
    
    var user: FUser?
    
    var selectedLanguage: String?
    
    var languageList = [NSLocalizedString("Arabic", comment: ""), NSLocalizedString("Standard Chinese (Mandarin)", comment: ""), NSLocalizedString("English", comment: ""), NSLocalizedString("French", comment: ""), NSLocalizedString("German", comment: ""),  NSLocalizedString("Hindi", comment: ""), NSLocalizedString("Italian", comment: ""), NSLocalizedString("Japanese", comment: ""), NSLocalizedString("Korean", comment: ""),  NSLocalizedString("Portuguese", comment: ""),  NSLocalizedString("Russian", comment: ""), NSLocalizedString("Spanish", comment: "")]
    
    var startIndex: Int?
    
    var hud = JGProgressHUD(style: .dark)
    
//    var auth = firebase.auth();
//    var emailAddress = emailTextField.text
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Do any additional setup after loading the view.
        languagePicker.delegate = self as UIPickerViewDelegate
        languagePicker.dataSource = self as UIPickerViewDataSource
        
        startIndex = languageList.count / 2
        
        languagePicker.selectRow(startIndex!, inComponent: 0, animated: true)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        let selectedLanguage = languageSelect(langIndex: languageIndex)
        print("!!!!!!!!! \(selectedLanguage) !!!!!!!!!")
        

        guard let email = emailTextField.text, email != "" else {
            hud.textLabel.text = NSLocalizedString("Please enter an email address for password reset", comment: "")
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.5)
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if error != nil {
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.textLabel.text = error?.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 1.5)
            }
            
            self.dismissKeyboard()
            //show success message
            
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            self.hud.textLabel.text = "We have just sent you a password reset email. Please check your inbox and follow the instructions to reset your password"
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.5)
        }
        
//        user?.resetpassword(email: email, onSuccess: {
//            self.dismissKeyboard()
//            //show success message
//            self.hud.indicatorView = JGProgressHUDIndicatorView()
//            self.hud.textLabel.text = "BEeeeeeeep Success"
//            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
//            self.hud.show(in: self.view)
//            self.hud.dismiss(afterDelay: 1.5)
//
//        }) { (error) in
//            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
//            self.hud.textLabel.text = error
//            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
//            self.hud.show(in: self.view)
//            self.hud.dismiss(afterDelay: 1.5)
//        }
        
        
    }
    
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        // dismisses keyboard
        self.view.endEditing(false)
    }
    
    // gets rid of any text in textFields
    func cleanTextFields() {
        emailTextField.text = ""
    }
    
    
    
//MARK: Picker menu functions

func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
}
func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return languageList.count
}
func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let row = languageList[row]
    return row
}
// change text color
func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return NSAttributedString(string: languageList[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
}
    
    func languageSelect(langIndex: Int) -> String {
           
           //        ["Arabic", "Bengali", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Hindi", "Italian", "Japenese", "Korean", "Malay", "Porteguese", "Romanian", "Russian", "Spanish"]
           
           var langIndex = langIndex
           
           langIndex = languagePicker.selectedRow(inComponent: 0)
           
           var languageValue = ""
           
                   if langIndex == 0 {
                   //arabic
                   languageValue = "ar"
               } else if langIndex == 1 {
                   //chinese
                   languageValue = "zh"
               } else if langIndex == 2 {
                   //english
                   languageValue = "en"
               } else if langIndex == 3 {
                   //french
                   languageValue = "fr"
               } else if langIndex == 4 {
                   //german
                   languageValue = "de"
               } else if langIndex == 5 {
                   //hindi
                   languageValue = "hi"
               } else if langIndex == 6 {
                   //italian
                   languageValue = "it"
               } else if langIndex == 7 {
                   //japense
                   languageValue = "ja"
               } else if langIndex == 8 {
                   //korean
                   languageValue = "ko"
               } else if langIndex == 9 {
                   //porteguese
                   languageValue = "pt"
               } else if langIndex == 10 {
                   //russian
                   languageValue = "ru"
               } else if langIndex == 11 {
                   //spanish
                   languageValue = "es"
               }
               return languageValue
           }
}
