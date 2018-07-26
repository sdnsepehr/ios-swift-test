//
//  NewNoteViewController.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit
import CoreData

class NewNoteViewController: UIViewController, TextEditingDelegate {
    
    lazy var titleTextFeild: SDNTextField = {
        let textField = SDNTextField();
        textField.textField.font = Style.normalFont;
        textField.isMandatory = true;
        textField.textEditingDelegate = self;
        textField.placeholder = "Note title".localized;
        textField.translatesAutoresizingMaskIntoConstraints = false;
        return textField;
    }();
    
    let detailsTextView: SDNTextView = {
        let textView = SDNTextView();
        textView.font = Style.normalFont;
        textView.isBordered = true;
        textView.placeholder = "Note details";
        textView.translatesAutoresizingMaskIntoConstraints = false;
        return textView;
    }();
    
    let colorIndicatorStackView: UIStackView = {
        let statckView = UIStackView();
        statckView.axis = .horizontal;
        statckView.alignment = .center;
        statckView.distribution = .fillEqually;
        statckView.spacing = 8;
        statckView.translatesAutoresizingMaskIntoConstraints = false;
        return statckView;
    }();
    
    lazy var alertSwitch: UISwitch = {
        let switch_ = UISwitch();
        switch_.thumbTintColor = Style.differColor;
        switch_.onTintColor = Style.mainColor;
        switch_.addTarget(self, action: #selector(switchStateChanged), for: .valueChanged);
        switch_.isOn = false;
        switch_.translatesAutoresizingMaskIntoConstraints = false;
        return switch_;
    }();
    
    let alertLabel: UILabel = {
        let label = UILabel();
        label.text = "Add alert for this note".localized.uppercased();
        label.font = Style.smallerFont;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let alertIconImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.image = #imageLiteral(resourceName: "notification-icon").withRenderingMode(.alwaysTemplate);
        imageView.tintColor = Style.mainColor.withAlphaComponent(0.8);
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        return imageView;
    }();
    
//    let notificationTitleBackgroundView: UIView = {
//        let view = UIView();
//        view.backgroundColor = Style.mainColor.withAlphaComponent(0.1);
//        view.translatesAutoresizingMaskIntoConstraints = false;
//        return view;
//    }();
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker();
        picker.datePickerMode = .dateAndTime;
        return picker;
    }();
    
    let alertDateTextField: UITextField = {
        let textField = UITextField();
        textField.placeholder = "";
        textField.font = Style.smallFont;
        textField.translatesAutoresizingMaskIntoConstraints = false;
        return textField;
    }();
    
    var doneBarButton: UIBarButtonItem?
    
    
    let colors = [Style.lightGrayColor, Style.blueColor, Style.greenColor, Style.orangeColor, Style.yellowColor];
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var selectedColor: UIColor = Style.lightGrayColor;
    var selectedColorButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = .white;
        title = "New Note".localized;
        
        view.addSubview(titleTextFeild);
        view.addSubview(detailsTextView);
        view.addSubview(colorIndicatorStackView);
        view.addSubview(alertIconImageView);
        view.addSubview(alertLabel);
        view.addSubview(alertSwitch);
        view.addSubview(alertDateTextField);
        
        doneBarButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(doneTap));
        doneBarButton?.isEnabled = false;
        let cancelBarButton = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: #selector(cancelTap));
        
        self.navigationItem.leftBarButtonItem = cancelBarButton;
        self.navigationItem.rightBarButtonItem = doneBarButton;
        
        for (i, color) in colors.enumerated() {
            addViewToStackWith(tag: i, color: color!);
        }
        
        setupConstraints();
    }
    
    func isTextViewEmpty(_ empty: Bool) {
        self.doneBarButton?.isEnabled = !empty;
    }
    
    
    private func addViewToStackWith(tag: Int, color: UIColor) {
        let colorIndicatorButton = UIButton(type: .custom);
        colorIndicatorButton.tag = tag;
        colorIndicatorButton.layer.cornerRadius = 10;
        colorIndicatorButton.layer.masksToBounds = true;
        colorIndicatorButton.backgroundColor = color;
        colorIndicatorButton.addTarget(self, action: #selector(colorButtonTapp(_:)), for: .touchUpInside);
        if(tag == 0) {
            self.selectColorButton(colorIndicatorButton);
        }
        self.colorIndicatorStackView.addArrangedSubview(colorIndicatorButton);
    }
    
    @objc private func colorButtonTapp(_ button: UIButton) {
        print("Tapped, ", button.tag);
            self.deselectColorButton(self.selectedColorButton);
            self.selectColorButton(button);
    }
    
    
    private func selectColorButton(_ button: UIButton) {
        button.layer.borderWidth = 1;
        button.layer.borderColor = Style.mainColor.withAlphaComponent(0.5).cgColor;
        self.selectedColorButton = button;
        print("Selected color index is: ", button.tag);
        self.selectedColor = colors[button.tag]!;
    }
    
    private func deselectColorButton(_ button: UIButton?) {
        guard let button = button else { return }
        button.layer.borderWidth = 0;
    }
    
    
    @objc private func cancelTap() {
        self.dismiss(animated: true, completion: nil);
    }
    
    @objc private func switchStateChanged() {
        if alertSwitch.isOn {
            self.showDatePicker();
        } else {
            self.alertLabel.text = "Add alert for this note".localized.uppercased();
            self.view.endEditing(true);
        }
    }
  
    @objc private func doneTap() {
        guard let title = titleTextFeild.text, !title.isEmpty else { return }
        let alertDate = alertSwitch.isOn ? datePicker.date : nil;
        let details = detailsTextView.text;
        let isalertOn = self.alertSwitch.isOn;
        
        container?.performBackgroundTask { context in
            if title.isEmpty { return }
            _ = try? Note.createNote(title: title, details: details, isalertOn: isalertOn, alertDate: alertDate, color: self.selectedColor, in: context);
            try? context.save();
            
             NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAlertStatus"), object: nil);
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    // ========================== Date picker functions ====================
    
    func showDatePicker(){
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit();
        let doneButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
        let cancelButton = UIBarButtonItem(title: "Cancel".localized, style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false);
        
        alertDateTextField.inputAccessoryView = toolbar;
        alertDateTextField.inputView = datePicker;
        alertDateTextField.becomeFirstResponder();
    }
    
    @objc func donedatePicker(){
        let formatter = DateFormatter();
        formatter.dateFormat = "h:mm a ' ' MMM d, yyyy";
        alertLabel.text = formatter.string(from: datePicker.date);
        self.view.endEditing(true);
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true);
    }
}

extension NewNoteViewController {
    fileprivate func setupConstraints() {
//        titleTextFeild
        titleTextFeild.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true;
        titleTextFeild.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true;
        titleTextFeild.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true;
        titleTextFeild.heightAnchor.constraint(equalToConstant: 56).isActive = true;
        
//        detailsTextView
        detailsTextView.topAnchor.constraint(equalTo: titleTextFeild.bottomAnchor).isActive = true;
        detailsTextView.leadingAnchor.constraint(equalTo: titleTextFeild.leadingAnchor).isActive = true;
        detailsTextView.trailingAnchor.constraint(equalTo: titleTextFeild.trailingAnchor).isActive = true;
        detailsTextView.heightAnchor.constraint(equalToConstant: 160).isActive = true;
        
//        colorIndicatorStackView
        colorIndicatorStackView.topAnchor.constraint(equalTo: detailsTextView.bottomAnchor, constant: 10).isActive = true;
        colorIndicatorStackView.leadingAnchor.constraint(equalTo: detailsTextView.leadingAnchor).isActive = true;
        colorIndicatorStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true;
        colorIndicatorStackView.heightAnchor.constraint(equalToConstant: 24).isActive = true;
        
//        alertIconImageView
        alertIconImageView.leadingAnchor.constraint(equalTo: colorIndicatorStackView.leadingAnchor).isActive = true;
        alertIconImageView.topAnchor.constraint(equalTo: colorIndicatorStackView.bottomAnchor, constant: 30).isActive = true;
        alertIconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true;
        alertIconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true;
        
//        alertLabel
        alertLabel.leadingAnchor.constraint(equalTo: alertIconImageView.trailingAnchor, constant: 10).isActive = true;
        alertLabel.centerYAnchor.constraint(equalTo: alertIconImageView.centerYAnchor).isActive = true;
        
//        alertSwitch
        alertSwitch.trailingAnchor.constraint(equalTo: detailsTextView.trailingAnchor).isActive = true;
        alertSwitch.centerYAnchor.constraint(equalTo: alertIconImageView.centerYAnchor).isActive = true;
        
//        alertDateTextField
        alertDateTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true;
        alertDateTextField.leadingAnchor.constraint(equalTo: alertLabel.leadingAnchor).isActive = true;
    }
}
