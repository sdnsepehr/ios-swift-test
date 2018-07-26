//
//  SDNTextView.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit

class SDNTextView: UITextView, UITextViewDelegate {
    var textEditingDelegate: TextEditingDelegate?
    
    lazy var placeHolderTextView: UITextView = {
        let textView = UITextView();
        textView.font = Style.normalFont;
        textView.isEditable = false;
        textView.isScrollEnabled = false;
        textView.textColor = Style.defaultTextColor.withAlphaComponent(0.6);
        textView.isSelectable = false;
        textView.backgroundColor = .clear;
        textView.translatesAutoresizingMaskIntoConstraints = false;
        let tap = UITapGestureRecognizer(target: self, action: #selector(placeholderTap));
        textView.addGestureRecognizer(tap);
        return textView;
    }();
    
    var placeholder: String? {
        didSet {
            placeHolderTextView.text = placeholder;
        }
    }
    
    override var font: UIFont? {
        didSet {
            self.placeHolderTextView.font = font;
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer);
        self.addSubview(placeHolderTextView);
        
        // Set UITextView Delegate
        delegate = self;
        self.layer.cornerRadius = self.borderRadius;
        self.layer.masksToBounds = true;
        
        setupConstraints();
    }
    
    @objc private func placeholderTap(){
        self.becomeFirstResponder();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        //        placeholderLabel
        placeHolderTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        placeHolderTextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true;
        placeHolderTextView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.isEmpty){
            placeHolderTextView.isHidden = false;
            self.textEditingDelegate?.isTextViewEmpty(true);
        } else {
            self.textEditingDelegate?.isTextViewEmpty(false);
            placeHolderTextView.isHidden = true;
        }
    }
    
    var textFieldTag: Int = 0;
    var isBordered = false {
        didSet {
            if(isBordered){
                self.layer.borderWidth = 1;
                self.layer.borderColor = BorderColors.emptyInputBorderColor.cgColor;
            }
        }
    }
    
    var borderRadius: CGFloat = 3 {
        didSet {
            self.layer.cornerRadius = borderRadius;
            self.layer.masksToBounds = true;
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(isBordered){
            self.layer.borderColor = BorderColors.selectedInputBorderColor.cgColor;
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(isBordered){
            if(textView.text.isEmpty){
                self.layer.borderColor = BorderColors.emptyInputBorderColor.cgColor;
            } else {
                self.layer.borderColor = BorderColors.filledInputBorderColor.cgColor;
            }
        }
    }
}

protocol TextEditingDelegate {
    func isTextViewEmpty(_ empty: Bool);
}

