//
//  TextField.swift
//  Recipee
//
//  Created by Alex on 09/01/2023.
//

import UIKit

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
