//
//  UITextField+Utils.swift
//  Recipee
//
//  Created by Alex on 09/01/2023.
//

import UIKit

extension TextField {
    static func createRoundedTextField() -> TextField {
        let textField = TextField()
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
        textField.tintColor = .black
        textField.clearButtonMode = .always
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 20
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.clipsToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}
