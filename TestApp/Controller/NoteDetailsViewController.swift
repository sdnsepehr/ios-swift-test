//
//  NoteDetailsViewController.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/27/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit

class NoteDetailsViewController: UIViewController, UITextViewDelegate {

    var note: Note? {
        didSet {
            title = note?.title;
            detailsTextView.text = note?.details;
        }
    }
    var isDone: Bool = false {
        didSet {
            self.detailsTextView.isEditable = !isDone;
        }
    }
    
    lazy var detailsTextView: UITextView = {
        let textView = UITextView();
        textView.delegate = self;
        textView.showsVerticalScrollIndicator = false;
        textView.showsHorizontalScrollIndicator = false;
        textView.contentMode = .scaleAspectFit;
        textView.font = Style.normalFont;
        textView.textColor = Style.defaultTextColor;
        textView.translatesAutoresizingMaskIntoConstraints = false;
        return textView;
    }();
    
    var savBarButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        view.backgroundColor = .white;
        savBarButton = UIBarButtonItem(title: "Save".localized, style: .done, target: self, action: #selector(updateTask));
        savBarButton?.isEnabled = false;
        navigationItem.rightBarButtonItem = savBarButton;
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil);
        
        view.addSubview(detailsTextView);
        
        setupConstraints();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
       NotificationCenter.default.removeObserver(self);
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardSize.cgRectValue.height;
            textViewBottonAnchor?.constant = -(keyboardHeight + 16);
            
            if let durationValue = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
                let duration = durationValue.doubleValue;
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded();
                })
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        textViewBottonAnchor?.constant = -16;
        if let durationValue = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
            let duration = durationValue.doubleValue;
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded();
            })
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let details = note?.details else { return }
        self.savBarButton?.isEnabled = textView.text != details;
    }
    
    @objc private func updateTask() {
        note?.updateDetails(updatedDetails: self.detailsTextView.text);
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    var textViewBottonAnchor: NSLayoutConstraint?
    private func setupConstraints() {
//        detailsTextView
        detailsTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true;
        detailsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true;
        detailsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true;
        textViewBottonAnchor = detailsTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16);
        textViewBottonAnchor?.isActive = true;
        
    }
}
