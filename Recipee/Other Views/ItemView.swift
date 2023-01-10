//
//  ItemView.swift
//  Recipee
//
//  Created by Alex on 04/01/2023.
//

import UIKit

class ItemView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .appFont(of: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let checkButton: UIButton = {
        let button =  UIButtonBuilder(of: .custom)
            .setImage(UIImage(systemName: "circle"))
            .setTintColor(.black)
            .setTAMIC(false)
            .create()
        button.tag = 0
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        translatesAutoresizingMaskIntoConstraints = false
        checkButton.addTarget(self, action: #selector(checkTapped), for: .touchUpInside)
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkTapped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func checkTapped() {
        if checkButton.tag == 0 {
            checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: [])
            checkButton.tag = 1
            titleLabel.attributedText = NSAttributedString(string: titleLabel.attributedText?.string ?? "", attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ])
        } else if checkButton.tag == 1 {
            checkButton.setImage(UIImage(systemName: "circle"), for: [])
            titleLabel.attributedText = NSAttributedString(string: titleLabel.attributedText?.string ?? "")
            checkButton.tag = 0
        }
    }
    
    private func layout() {
        addSubview(checkButton)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.5),
            checkButton.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.5),
            bottomAnchor.constraint(equalToSystemSpacingBelow: checkButton.bottomAnchor, multiplier: 0.5),
            
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: checkButton.trailingAnchor, multiplier: 1),
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.5),
            bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 0.5),
            trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1)
        ])
        
        checkButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func configure(with text: String) {
        titleLabel.attributedText = NSAttributedString(string: text)
    }
}
