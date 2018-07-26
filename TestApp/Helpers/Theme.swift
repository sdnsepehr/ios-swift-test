//
//  Theme.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit

enum Theme: String {
    case default_ = "default";
    
    static var currentTheme: Theme {
        get {
            if UserDefaults.standard.value(forKey: KeyStrings.currentTheme) != nil {
                return Theme(rawValue: UserDefaults.standard.value(forKey: KeyStrings.currentTheme) as! String)!;
            } else {
                return Theme.default_;
            }
        }
        set {
            Style.setupTheme(theme: newValue);
        }
    }
}

struct Style {
    
    // ======= Colors ============
    static var mainColor: UIColor!
    static var differColor: UIColor!
    static var defaultTextColor: UIColor!
    static var errorColorRed: UIColor!
    static var grayColor: UIColor!
    
    // Note titles background color
    static var blueColor: UIColor!
    static var greenColor: UIColor!
    static var orangeColor: UIColor!
    static var yellowColor: UIColor!
    static var lightGrayColor: UIColor!
    static var notificationGreenColor: UIColor!
    
    // ======= Fonts =============
    static var veryBigFont: UIFont!
    static var biggerFont: UIFont!
    static var normalFont: UIFont!
    static var normalBoldFont: UIFont!
    static var smallFont: UIFont!
    static var smallerFont: UIFont!
    static var miniFont: UIFont!
    
    static func setupTheme(theme: Theme){
        UserDefaults.standard.setValue(theme.rawValue, forKey: KeyStrings.currentTheme);
        
        switch theme {
        case .default_:
            setupDefaultTheme();
        }
    }
    
    private static func setupDefaultTheme(){
        // -------- Colors ----------------
        mainColor = UIColor(r: 31, g: 71, b: 98);
        differColor = UIColor(r: 245, g: 186, b: 52);
        defaultTextColor = UIColor(r: 57, g: 65, b: 71);
        errorColorRed = UIColor(r: 255, g: 23, b: 51);
        grayColor = UIColor(r: 52, g: 60, b: 66);
        notificationGreenColor = UIColor(r: 35, g: 198, b: 89);
        
        blueColor = UIColor(r: 228, g: 243, b: 252);
        greenColor = UIColor(r: 223, g: 245, b: 222);
        orangeColor = UIColor(r: 253, g: 240, b: 232);
        yellowColor = UIColor(r: 251, g: 250, b: 216);
        lightGrayColor =  UIColor(r: 242, g: 242, b: 242);
        
        // -------- Fonts ----------------
        veryBigFont = UIFont.systemFont(ofSize: 30);
        biggerFont = UIFont.systemFont(ofSize: 20);
        normalFont = UIFont.systemFont(ofSize: 16);
        normalBoldFont = UIFont.boldSystemFont(ofSize: 15);
        smallerFont = UIFont.systemFont(ofSize: 13);
        smallFont = UIFont.systemFont(ofSize: 11);
        miniFont = UIFont.systemFont(ofSize: 9);
       
    }
}
