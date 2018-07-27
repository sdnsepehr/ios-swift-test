//
//  ParentNavigationController.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit

class ParentNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationBar.barTintColor = .white;
        self.navigationBar.isTranslucent = false;
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Style.mainColor, NSAttributedStringKey.font: Style.normalFont];
        self.navigationBar.tintColor = Style.mainColor;
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: Style.mainColor], for: .normal);
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, 0), for:UIBarMetrics.default)
    }
}
