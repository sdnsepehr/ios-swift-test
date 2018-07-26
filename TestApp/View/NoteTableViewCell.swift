//
//  NoteTableViewCell.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit
import UserNotifications

enum AlertStatus {
    case active, inactive;
}

class NoteTableViewCell: UITableViewCell {
    
    var alertDelegate: AlertDelegate?
    
    var note: Note? {
        didSet {
            titleLabel.text = note?.title;
            updatedDateLabel.text = note?.updatedDateString();
            alertDateLabel.text = note?.alertDateString();
            
            if let colorHex = note?.colorHex {
                backgroundColorView.backgroundColor = UIColor(hex: colorHex);
            } else {
                backgroundColorView.backgroundColor = Style.lightGrayColor;
            }
            
            if let isDone = note?.isDone, isDone {
                backgroundColorView.alpha = 0.6;
                alertOnOffButton.isHidden = true;
            } else {
                backgroundColorView.alpha = 1;
                alertOnOffButton.isHidden = false;
            }
            
            if let alertOn = note?.isAlertOn, let alertDate = note?.alertDate, (alertOn && alertDate > Date()) {
                changeAlertIconStatus(status: .active);
            } else  {
                changeAlertIconStatus(status: .inactive);
            }
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel();
        label.textColor = Style.defaultTextColor;
        label.font = Style.normalBoldFont;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }()
    
    let updatedDateLabel: UILabel = {
        let label = UILabel();
        label.textColor = Style.defaultTextColor;
        label.font = Style.smallFont;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }()
    
    let alertIconImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.image = #imageLiteral(resourceName: "notification-icon").withRenderingMode(.alwaysTemplate);
        imageView.tintColor = Style.notificationGreenColor;
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        return imageView;
    }();
    
    let alertDateLabel: UILabel = {
        let label = UILabel();
        label.textColor = Style.defaultTextColor;
        label.font = Style.miniFont;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }()
    
    lazy var alertOnOffButton: UIButton = {
        let button = UIButton(type: .custom);
        button.addTarget(self, action: #selector(alertTapped), for: .touchUpInside);
        button.setImage(#imageLiteral(resourceName: "notification-icon").withRenderingMode(.alwaysTemplate), for: .normal);
        button.imageView?.tintColor = Style.mainColor;
        button.imageView?.contentMode = .scaleAspectFit;
        button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 35, bottom: 25, right: 15);
        button.translatesAutoresizingMaskIntoConstraints = false;
        return button;
    }()
    
    let backgroundColorView: UIView = {
        let view = UIView();
        view.layer.cornerRadius = 2;
        view.layer.masksToBounds = true;
        view.translatesAutoresizingMaskIntoConstraints = false;
        return view;
    }();
    
    
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        selectionStyle = .none;
        
        self.addSubview(alertDateTextField);
        addSubview(backgroundColorView);
        backgroundColorView.addSubview(titleLabel);
        backgroundColorView.addSubview(updatedDateLabel);
        backgroundColorView.addSubview(alertDateLabel);
        backgroundColorView.addSubview(alertIconImageView);
        backgroundColorView.addSubview(alertOnOffButton);
        
        setupConstraints();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func changeAlertIconStatus(status: AlertStatus) {
        
        self.alertIconImageView.isHidden = note?.alertDate == nil;
        
        if(status == .active){
            self.alertIconImageView.tintColor = Style.notificationGreenColor;
            self.alertDateLabel.textColor = Style.defaultTextColor;
            self.alertOnOffButton.imageView?.tintColor = Style.differColor;
            self.alertOnOffButton.alpha = 1;
        } else {
            self.alertIconImageView.tintColor = Style.errorColorRed;
            self.alertDateLabel.textColor = Style.errorColorRed;
            self.alertOnOffButton.imageView?.tintColor = Style.mainColor;
            self.alertOnOffButton.alpha = 0.3;
        }
    }
    
    @objc private func alertTapped() {
        if(alertOnOffButton.alpha == 1) {
            self.changeAlertIconStatus(status: .inactive);
            self.updateNoteAlert(date: nil);
        } else {
            self.showDatePicker();
        }
    }
    
    private func updateNoteAlert(date: Date?) {
        if(date == nil) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications();
        }
        self.note?.updateAlertDate(date: date);
        self.alertDelegate?.reloadNotes();
    }
    
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
        let date = datePicker.date;
        self.updateNoteAlert(date: date)
    }
    
    @objc func cancelDatePicker(){
        self.endEditing(true);
    }
    
    private func setupConstraints() {
        
        //        backgroundColorView
        backgroundColorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true;
        backgroundColorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true;
        backgroundColorView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true;
        backgroundColorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4).isActive = true;
        
        //        titleLabel
        titleLabel.topAnchor.constraint(equalTo: backgroundColorView.topAnchor, constant: 12).isActive = true;
        titleLabel.leadingAnchor.constraint(equalTo: backgroundColorView.leadingAnchor, constant: 16).isActive = true;
        titleLabel.trailingAnchor.constraint(equalTo: backgroundColorView.trailingAnchor, constant: -16).isActive = true;
        
        //        updatedDateLabel
        updatedDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true;
        updatedDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true;
        
        //        alertIconImageView
        alertIconImageView.topAnchor.constraint(equalTo: updatedDateLabel.bottomAnchor, constant: 5).isActive = true;
        alertIconImageView.leadingAnchor.constraint(equalTo: updatedDateLabel.leadingAnchor).isActive = true;
        alertIconImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true;
        alertIconImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true;
        
        //        alertDateLabel
        alertDateLabel.centerYAnchor.constraint(equalTo: alertIconImageView.centerYAnchor).isActive = true;
        alertDateLabel.leadingAnchor.constraint(equalTo: alertIconImageView.trailingAnchor, constant: 3).isActive = true;
        
        //        alertOnOffButton
        alertOnOffButton.trailingAnchor.constraint(equalTo: backgroundColorView.trailingAnchor).isActive = true;
        alertOnOffButton.centerYAnchor.constraint(equalTo: backgroundColorView.centerYAnchor).isActive = true;
        alertOnOffButton.widthAnchor.constraint(equalToConstant: 70).isActive = true;
        alertOnOffButton.heightAnchor.constraint(equalToConstant: 70).isActive = true;
        
        //        alertDateTextField
        alertDateTextField.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        alertDateTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        
    }
}

protocol AlertDelegate {
    func reloadNotes();
}
