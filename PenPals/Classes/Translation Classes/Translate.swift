//
//  Translate.swift
//  PenPals
//
//  Created by MaseratiTim on 4/9/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import Foundation

class Translate {
    
    
    var code = "fr"
    
    func detectlanguage(text: String) {
        
        TranslationManager.shared.detectLanguage(forText: text) { (language) in
            
            if let language = language {
                print("The detected language was \(language)")

            } else {
                print("Oops! It seems that something went wrong and language cannot be detected.... detetcLanguage()")
            }
            
        }
    }
    
    func getTargetLangCode(code: String) {
        
        TranslationManager.shared.targetLanguageCode = code
        print("getTargetLanguage(\(code))")
    }
    
    func translate(text: String) {
        //            checkForLanguagesExistence()
        getTargetLangCode(code: code)
        TranslationManager.shared.textToTranslate = text
        print("translate(\(text))")
        
    }
    
    func initiateTranslation(text: String) {
        
        var text = text
        
        //has the correct code
        
        translate(text: text)
        print("this the current text message \(text) !!!!!")
        
        //this code is not being called
        TranslationManager.shared.translate { (translation) in
            if let translation = translation {
                
                text = translation
                print("Th translation is... \(text)")
            } else {
                print("Oops! It seems that something went wrong and translation cannot be done... initiateTranslation()")
            }
            
        }
        
    }
    
    
}
