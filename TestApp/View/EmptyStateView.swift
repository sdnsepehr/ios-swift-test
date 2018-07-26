//
//  EmptyStateView.swift
//  TestApp
//
//  Created by Saifuddin Sepehr on 7/26/18.
//  Copyright © 2018 AlayaCare. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFit;
        imageView.image = #imageLiteral(resourceName: "no-notes").withRenderingMode(.alwaysTemplate);
        imageView.tintColor = Style.mainColor;
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        return imageView;
    }();
    
    let titleLabel: UILabel = {
        let label = UILabel();
        label.font = Style.normalBoldFont;
        label.textColor = Style.defaultTextColor;
        label.textAlignment = .center;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }();
    
    let descriptionLabel: UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.font = Style.normalFont;
        label.textColor = Style.defaultTextColor.withAlphaComponent(0.7);
        label.textAlignment = .center;
        label.translatesAutoresizingMaskIntoConstraints = false;
        return label;
    }()
    
    convenience init(message: String) {
        self.init(frame: CGRect.zero);
        self.descriptionLabel.text = message;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = .white;
        
        self.addSubview(iconImageView);
        self.addSubview(titleLabel);
        self.addSubview(descriptionLabel);
        
        setupConstraints();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints(){
        iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 65).isActive = true;
        iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        iconImageView.widthAnchor.constraint(equalToConstant: 65).isActive = true;
        iconImageView.heightAnchor.constraint(equalToConstant: 65).isActive = true;
        
        titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 14).isActive = true;
        titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true;
        titleLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true;
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true;
        descriptionLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 0.9).isActive = true;
        descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
    }
}
