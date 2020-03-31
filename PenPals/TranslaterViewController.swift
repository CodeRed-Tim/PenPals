//
//  TranslaterViewController.swift
//  PenPals
//
//  Created by Eric Alves on 2/28/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TranslaterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerLang.delegate = self
    }
    
    // Variables
    var arrayOfCountries = ["English","Spanish","French","Portuguese", "Chinese","Russian", "Italian"]
    @IBOutlet weak var translateTextField: UITextField!
    @IBOutlet weak var translatedTextLabel: UILabel!
    @IBOutlet weak var pickerLang: UIPickerView!
    var languageIdentified: String = ""
    

    // Calls functions when button is pressed
    @IBAction func translateButton(_ sender: Any) {
        identifyLanguage()
    }
    
    //Gets Language Receiver and Sender are using inorder to pass to identifyLanguageCode()
    func identifyLanguage(){
            let languageId = NaturalLanguage.naturalLanguage().languageIdentification()
            
            languageId.identifyLanguage(for: self.translateTextField.text ?? "") { (languageCode, error) in
                if let error = error {
                    print("Failed with error: \(error)")
                    return
                }
                if let languageCode = languageCode, languageCode != "und" {
                    self.languageIdentified = languageCode
                    self.identifyLanguageCode()
                } else {
                    self.translatedTextLabel.text = "Input is Unknown"
                }
            }
    }
    
    // Gets Language Code from Receiver and Sender to pass to toTranslate()
    func identifyLanguageCode(){
            
            let allLanguages = TranslateLanguage.allLanguages()
            var languageCode = TranslateLanguage.en.rawValue
            
            for number in allLanguages{
                    
                    let language = TranslateLanguage(rawValue: UInt(truncating: number))
                    
                    if let code = language?.toLanguageCode(){
                        if self.languageIdentified == code{
                            languageCode = UInt(truncating: number)
                            break
                        }
                    }
            }
            
            toTranslate(languageCode: languageCode)

    }
    
    //With the Language Code, function will translate input text to desire language
    func toTranslate(languageCode: UInt) {
        //Code to use on-device translater to French
        //Step 1
        let options = TranslatorOptions(sourceLanguage: TranslateLanguage(rawValue: languageCode)!, targetLanguage: .en)
        let englishFrenchTranslator = NaturalLanguage.naturalLanguage().translator(options: options)
        //Step 2
        englishFrenchTranslator.downloadModelIfNeeded { (error) in
        guard error == nil else {
            return }
        }
        //Step 3
        englishFrenchTranslator.translate(self.translateTextField.text ?? "") { (translatedText, error) in
            guard error == nil, let translatedText = translatedText else {
                return }
            self.translatedTextLabel.text = translatedText
            }
    }
    
    
    // UIPicker for desplaying Language
        func numberOfComponents(in pickerLang: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerLang: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return arrayOfCountries.count
        }
        
        func pickerView(_ pickerLang: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
            return arrayOfCountries[row]
        }
        
        func pickerView(_ pickerLang: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        }
    
}//End Class
