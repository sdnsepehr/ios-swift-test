//
//  SDNTextField.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit

enum MessageType {
    case error
    case warning
    case normal
}

class SDNTextField: UIView, UITextFieldDelegate {
    
    var isMandatory = false;
    var textEditingDelegate: TextEditingDelegate?
    
    lazy var textField: UITextField = {
        let textField = UITextField();
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5));
        textField.rightView = paddingView;
        textField.leftView = paddingView;
        textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged);
        textField.leftViewMode = .always;
        textField.delegate = self;
        textField.font = Style.normalFont;
        textField.layer.cornerRadius = 2;
        textField.layer.borderColor = Style.lightGrayColor.cgColor;
        textField.layer.borderWidth = 1;
        textField.layer.masksToBounds = true;
        textField.textColor = Style.defaultTextColor;
        textField.rightViewMode = .always;
        textField.translatesAutoresizingMaskIntoConstraints = false;
        return textField;
    }();
    
    let noteCommentLabel: UILabel = {
        let label = UILabel();
        label.font = Style.smallFont;
        label.textColor = Style.defaultTextColor.withAlphaComponent(0.7);
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.tintColor = Style.lightGrayColor;
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        return imageView;
    }();
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.addSubview(iconImageView);
        self.addSubview(textField);
        self.addSubview(noteCommentLabel);
        
        setupUILayout();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var iconImage: UIImage? {
        didSet { if let image = iconImage?.withRenderingMode(.alwaysTemplate) { self.iconImageView.image = image }}
    }
    
    var text: String? {
        get { return textField.text }
        set { self.textField.text = newValue }
    }
    
    var firstResponder: Bool! {
        didSet {
            if(firstResponder) {
                self.textField.becomeFirstResponder();
            } else {
                self.textField.resignFirstResponder();
            }
        }
    }
    
    private func setupPasswordInputView(){
        textField.keyboardType = .asciiCapable;
        textField.isSecureTextEntry = true;
    }
    
    func setMessage(text: String, type: MessageType) {
        if(!isMandatory) { return }
        noteCommentLabel.text = text;
        
        switch type {
        case .error:
            noteCommentLabel.textColor = Style.errorColorRed;
        case .warning:
            noteCommentLabel.textColor = Style.errorColorRed;
        case .normal:
            noteCommentLabel.textColor = Style.defaultTextColor.withAlphaComponent(0.7);
        }
    }
    
    @objc private func textChanged(_ textField: UITextField){
        noteCommentLabel.text = "";
        if(textField.text!.isEmpty){
            self.textEditingDelegate?.isTextViewEmpty(true);
        } else {
            self.textEditingDelegate?.isTextViewEmpty(false);
        }
    }
    
    private func setupUILayout(){
        //        noteCommentLabel
        noteCommentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true;
        noteCommentLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true;
        noteCommentLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true;
        noteCommentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        
        //   textField
        textField.bottomAnchor.constraint(equalTo: noteCommentLabel.topAnchor).isActive = true;
        textField.leadingAnchor.constraint(equalTo: noteCommentLabel.leadingAnchor).isActive = true;
        textField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        textField.widthAnchor.constraint(equalTo: noteCommentLabel.widthAnchor).isActive = true;
        
        //        iconImage
        iconImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true;
        iconImageView.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -10).isActive = true;
        iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true;
        iconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true;
        
    }
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        noteCommentLabel.text = "";
        self.textField.layer.borderColor = BorderColors.selectedInputBorderColor.cgColor;
        self.iconImageView.tintColor = BorderColors.selectedInputBorderColor;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (textField.text!.isEmpty) {
            self.textField.layer.borderColor = BorderColors.emptyInputBorderColor.cgColor;
            self.iconImageView.tintColor = BorderColors.emptyInputBorderColor;
                self.setMessage(text: "Title can't be empty".localized, type: .warning);
        } else {
            self.textField.layer.borderColor = BorderColors.filledInputBorderColor.cgColor;
            self.iconImageView.tintColor = BorderColors.filledInputBorderColor;
        }
    }
}

struct BorderColors {
    static let emptyInputBorderColor = UIColor(r: 216, g: 223, b: 232);
    static let filledInputBorderColor = UIColor(r: 194, g: 215, b: 242);
    static let selectedInputBorderColor = UIColor(r: 160, g: 201, b: 255);
}

