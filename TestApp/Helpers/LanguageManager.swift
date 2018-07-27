//
//  LanguageManager.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import Foundation
enum Language: String {
    case english = "english";
}

enum LanguageCode: String {
   case englishCode = "en";
}

struct LanguageManager {
    
    static var currentLanguageCode: LanguageCode {
        get {
            if let languageCode = UserDefaults.standard.value(forKey: KeyStrings.currentLanguageCode) as? String {
                return LanguageCode(rawValue: languageCode)!;
            } else {
                return LanguageCode.englishCode;
            }
        }
    }
    
    
    static var currentLanguage: Language {
        get {
            if let language = UserDefaults.standard.value(forKey: KeyStrings.currentLanguage) as? String {
                return Language(rawValue: language)!;
            } else {
                return Language.english;
            }
        }
        
        set {
            
            switch currentLanguage {
            case .english:
                UserDefaults.standard.setValue(Language.english.rawValue, forKey: KeyStrings.currentLanguageCode);
                Locale.preferredLanguage = LanguageCode.englishCode.rawValue;

            }
            UserDefaults.standard.setValue(newValue.rawValue, forKey: KeyStrings.currentLanguage);
            UserDefaults.standard.synchronize();
        }
    }
}
