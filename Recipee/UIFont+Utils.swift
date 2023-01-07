//
//  UIFont+Utils.swift
//  Recipee
//
//  Created by Alex on 30/12/2022.
//

import UIKit

extension UIFont {
    static func appFont(of size: CGFloat, isBold: Bool = false) -> UIFont {
        return isBold ? UIFont.init(name: "Tinos-Bold", size: size)! :
        UIFont.init(name: "Tinos-Regular", size: size)!
    }
}
