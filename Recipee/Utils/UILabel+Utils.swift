//
//  UILabel+Utils.swift
//  Recipee
//
//  Created by Alex on 03/01/2023.
//

import UIKit

extension UILabel {

    func countLabelLines() -> Int {
        self.sizeToFit()
        let myText = self.text!
        let height = myText.height(withConstrainedWidth: UIScreen.main.bounds.width - 16, font: self.font)
        
        return Int(ceil(CGFloat(height) / self.font.lineHeight))
    }

    func isTruncated() -> Bool {
        if (self.countLabelLines() > self.numberOfLines) {
            return true
        }
        return false
    }
}
