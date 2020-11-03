//
//  RegisterViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 2/7/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JGProgressHUD
import PasswordTextField
import FlagPhoneNumber
import CountryPickerView

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordRulesLabel: UILabel!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var selectPpLabel: UILabel!
    @IBOutlet weak var tapPpLabel: UILabel!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var languageDropDown: UITextField!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    @IBOutlet weak var registerScrollView: UIScrollView!
    
    var myImageView: UIImageView!
    var myImage: UIImage!
    
    weak var cpvTextField: CountryPickerView!
    let cpvInternal = CountryPickerView()
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    var selectedLanguage: String?
    
    var languageList = [NSLocalizedString("Arabic", comment: ""), NSLocalizedString("Standard Chinese (Mandarin)", comment: ""), NSLocalizedString("English", comment: ""), NSLocalizedString("French", comment: ""), NSLocalizedString("German", comment: ""),  NSLocalizedString("Hindi", comment: ""), NSLocalizedString("Italian", comment: ""), NSLocalizedString("Japanese", comment: ""), NSLocalizedString("Korean", comment: ""),  NSLocalizedString("Portuguese", comment: ""),  NSLocalizedString("Russian", comment: ""), NSLocalizedString("Spanish", comment: "")]
    
    var startIndex: Int?
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsButton.titleLabel?.lineBreakMode = .byWordWrapping
        termsButton.titleLabel?.textAlignment = .center
        
        //Localization
        signUpLabel.text = NSLocalizedString("Sign Up", comment: "")
        firstNameLabel.text = NSLocalizedString("First Name", comment: "")
        firstNameTextField.placeholder = NSLocalizedString("First Name", comment: "")
        
        lastNameLabel.text = NSLocalizedString("Last Name", comment: "")
        lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "")
        
        emailLabel.text = NSLocalizedString("Email", comment: "")
        emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        
        phoneNumberLabel.text = NSLocalizedString("Phone Number", comment: "")
        phoneNumberTextField.placeholder = NSLocalizedString("Phone Number", comment: "")
        
        passwordLabel.text = NSLocalizedString("Passsword", comment: "")
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        passwordRulesLabel.text = NSLocalizedString("Password Rules", comment: "")
        
        confirmPasswordLabel.text = NSLocalizedString("Confirm Password", comment: "")
        confirmPasswordTextField.placeholder = NSLocalizedString("Confirm Password", comment: "")
        
        selectLabel.text = NSLocalizedString("Select Language", comment: "")
        selectPpLabel.text = NSLocalizedString("Select Profile Picture", comment: "")
        tapPpLabel.text = NSLocalizedString("Tap Profile Picture", comment: "")
        
        registerButton.setTitle(NSLocalizedString("Sign Up", comment: ""), for: .normal)
        termsButton.setTitle(NSLocalizedString("Terms", comment: ""), for: .normal)
        
        avatarImageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        languagePicker.delegate = self as UIPickerViewDelegate
        languagePicker.dataSource = self as UIPickerViewDataSource
        
        startIndex = languageList.count / 2
        
        languagePicker.selectRow(startIndex!, inComponent: 0, animated: true)
        
//        scrollViewDidScroll(scrollView: registerScrollView)
        
        
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
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
    
    
    //MARK: IBActions
    
    @IBAction func avatarImageTapped(_ sender: Any) {
        
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        presentPicker()
    }
    
    func presentPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func validatePhone(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: value)
        return result
    }
    
    func validatePass(value: String) -> Bool {
        let PASS_REGEX = "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{6,}$"
        let passTest = NSPredicate(format: "SELF MATCHES %@ ", PASS_REGEX)
        let result = passTest.evaluate(with: value)
        return result
    }
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        
        if emailTextField.text != "" && firstNameTextField.text != "" && lastNameTextField.text != "" && phoneNumberTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            
            //validates both passwords match
            if passwordTextField.text == confirmPasswordTextField.text {
                
                if validatePhone(value: phoneNumberTextField.text!) == true {
                    
                    if validatePass(value: passwordTextField.text!) == true {
                    
                    FUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, language: languageSelect(langIndex: languageIndex)) { (error) in
                        
                        if error != nil {
                            self.hud.dismiss()
                            self.hud.textLabel.text = "\(error!.localizedDescription)"
                            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                            self.hud.show(in: self.view)
                            self.hud.dismiss(afterDelay: 1.5)
                            return
                        }
                        self.registerUser()
                    }
                        
                    } else {
                        hud.indicatorView = JGProgressHUDErrorIndicatorView()
                        hud.textLabel.text = NSLocalizedString("Password Rules", comment: "")
                        hud.indicatorView = JGProgressHUDErrorIndicatorView()
                        hud.show(in: self.view)
                        hud.dismiss(afterDelay: 1.5)
                    }
                    
                } else {
                    hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    hud.textLabel.text = NSLocalizedString("Invalid Phone Number Format!", comment: "")
                    hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    hud.show(in: self.view)
                    hud.dismiss(afterDelay: 1.5)
                }
                
            } else {
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.textLabel.text = NSLocalizedString("Passwords don't match!", comment: "")
                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 1.5)
            }
        } else {
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = NSLocalizedString("All Fields are Required!", comment: "")
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.75)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        cleanTextFields()
        dismissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func termsButtonTapped(_ sender: Any) {
        let urlComponents = URLComponents (string: "http://www.slateofficial.com/terms.html")!
        UIApplication.shared.open (urlComponents.url!)
    }
    
    //MARK: Helper Functions
    
    func registerUser() {
        
        hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = NSLocalizedString("Registering you...", comment: "")
        hud.show(in: self.view)
        
        let firstName = firstNameTextField.text?.capitalizingFirstLetter()
        let lastName = lastNameTextField.text?.capitalizingFirstLetter()
        
        
        let fullName = firstName! + " " + lastName!
        let languageIndex = languagePicker.selectedRow(inComponent: 0)
        
        var tempDictionary : Dictionary = [kFIRSTNAME : firstName!, kLASTNAME : lastName!, kFULLNAME : fullName, kPHONE : phoneNumberTextField.text!, kLANGUAGE : languageSelect(langIndex: languageIndex)] as [String : Any]
        
        //if user doesn't pick a profile picture make the picture their intials
        if avatarImage == nil {
            
            // get intials then return them
            imageFromInitials(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (avatarInitials) in
                
                // converts image into a string so it can be saved in database
                let avatarImg = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarImg!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDictionary[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDictionary)
            }
            
        } else {
            
            let avatarData = avatarImageView.image!.jpegData(compressionQuality: 0.1)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDictionary[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDictionary)
            
        }
        
    }
    
    // pass dictionary and add info locally and to database
    func finishRegistration(withValues: [String : Any]) {
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            
            if error != nil {
                
                DispatchQueue.main.async {
                    self.hud.dismiss()
                    self.hud.textLabel.text = "\(error!.localizedDescription)"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 1.5)
                    
                    print(error!.localizedDescription)
                }
                return
            }
            
            self.hud.dismiss()
            self.goToApp()
        }
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
    
    
    //MARK: GoToApp
    
    func goToApp() {
        
        // clear progress message
        hud.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        // present app
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    
    //MARK: Navigation
    
    func dismissKeyboard() {
        // dismisses keyboard
        self.view.endEditing(false)
    }
    
    // gets rid of any text in textFields
    func cleanTextFields() {
        emailTextField.text = ""
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        phoneNumberTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
    }

}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UITextField {
    func showDoneButtonOnKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        
        var toolBarItems = [UIBarButtonItem]()
        toolBarItems.append(flexSpace)
        toolBarItems.append(doneButton)
        
        let doneToolbar = UIToolbar()
        doneToolbar.items = toolBarItems
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            avatarImage = imageSelected
            avatarImageView.image = imageSelected
            avatarImageView.image = avatarImage?.circleMasked
            
        }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            avatarImage = imageOriginal
            avatarImageView.image = imageOriginal
            avatarImageView.image = avatarImage?.circleMasked
        }
        
        avatarImageView.image = avatarImage!.fixedOrientation()
        avatarImageView.image = avatarImageView.image?.circleMasked
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {

    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
        // This is default orientation, don't need to do anything
        return self.copy() as? UIImage
    }

    guard let cgImage = self.cgImage else {
        // CGImage is not available
        return nil
    }

    guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        return nil // Not able to create CGContext
    }

    var transform: CGAffineTransform = CGAffineTransform.identity

    switch imageOrientation {
    case .down, .downMirrored:
        transform = transform.translatedBy(x: size.width, y: size.height)
        transform = transform.rotated(by: CGFloat.pi)
    case .left, .leftMirrored:
        transform = transform.translatedBy(x: size.width, y: 0)
        transform = transform.rotated(by: CGFloat.pi / 2.0)
    case .right, .rightMirrored:
        transform = transform.translatedBy(x: 0, y: size.height)
        transform = transform.rotated(by: CGFloat.pi / -2.0)
    case .up, .upMirrored:
        break
    @unknown default:
        break
    }

    // Flip image one more time if needed to, this is to prevent flipped image
    switch imageOrientation {
    case .upMirrored, .downMirrored:
        transform = transform.translatedBy(x: size.width, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored, .rightMirrored:
        transform = transform.translatedBy(x: size.height, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    case .up, .down, .left, .right:
        break
    @unknown default:
        break
    }

    ctx.concatenate(transform)

    switch imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    default:
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        break
    }

    guard let newCGImage = ctx.makeImage() else { return nil }
    return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}
