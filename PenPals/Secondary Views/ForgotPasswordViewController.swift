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

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var contactTextView: UITextView!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    var user: FUser?
    
    var hud = JGProgressHUD(style: .dark)
    
//    var auth = firebase.auth();
//    var emailAddress = emailTextField.text
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTextView()
    }
    
    func updateTextView() {
        
        contactTextView.text = NSLocalizedString("Forgot Email", comment: "")
        
        let path = "https://www.slateofficial.com/"
        let text = contactTextView.text ?? ""
        let attributedString = NSAttributedString.makeHyperLink(for: path, in: text, as: NSLocalizedString("Support Team", comment: ""))
        let font = contactTextView.font
        let textColor = contactTextView.textColor
        let align = contactTextView.textAlignment
        contactTextView.attributedText = attributedString
        contactTextView.font = font
        contactTextView.textColor = textColor
        contactTextView.textAlignment = align
        
        forgotPasswordLabel.text = NSLocalizedString("Forgot Password", comment: "")
        instructionsLabel.text = NSLocalizedString("Instructions", comment: "")
        emailLabel.text = NSLocalizedString("Email", comment: "")
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        resetPasswordButton.setTitle(NSLocalizedString("Reset Password", comment: ""), for: .normal)
        
        
    }
    
//    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        UIApplication.shared.open(URL)
//        return false
//    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        
//        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
//        let selectedLanguage = languageSelect(langIndex: languageIndex)
//        print("!!!!!!!!! \(selectedLanguage) !!!!!!!!!")
        

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
            self.hud.textLabel.text = NSLocalizedString("Email Sent", comment: "")
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
    
}
