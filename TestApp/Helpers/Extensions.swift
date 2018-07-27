//
//  Extensions.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        // Create a color by only passing the rgb values
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1);
    }
    
    // initialize a UIColor object by passing a hex string
    convenience init?(hex: String) {
        var hexNormalized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexNormalized = hexNormalized.replacingOccurrences(of: "#", with: "")
        
        // Helpers
        var rgb: UInt32 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexNormalized.count;
        
        // Create Scanner
        Scanner(string: hexNormalized).scanHexInt32(&rgb)
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // converts a UIColor to Hex String
    var toHex: String? {
        // Extracting components
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        // Create a Hex String from this color
        let hex = String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        
        return hex
    }
}

extension String {
    
    // When we decided to add localizations, we only need to call localized on any String and it will find the matched localized string and return.
    
    var localized: String {
        var result: String
        let languageCode = Locale.preferredLanguage;
        var path = Bundle.main.path(forResource: languageCode, ofType: "lproj");
        if path == nil, let index = languageCode.index(of: "-") {
            let languageCodeShort =  String(languageCode[..<index]);
            path = Bundle.main.path(forResource: languageCodeShort, ofType: "lproj");
        }
        
        if let path = path, let locBundle = Bundle(path: path) {
            result = locBundle.localizedString(forKey: self, value: nil, table: nil);
        } else {
            result = NSLocalizedString(self, comment: "");
        }
        return result
    }
}

extension Locale {
    static var preferredLanguage: String {
        get {
            return self.preferredLanguages.first ?? LanguageManager.currentLanguageCode.rawValue;
        }
        set {
            UserDefaults.standard.set([newValue], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
}
