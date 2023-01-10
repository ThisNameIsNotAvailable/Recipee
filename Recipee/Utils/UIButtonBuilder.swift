//
//  UIButtonBuilder.swift
//  Recipee
//
//  Created by Alex on 10/01/2023.
//

import UIKit

class UIButtonBuilder {
    private var button: UIButton
    
    init(of type: UIButton.ButtonType) {
        button = UIButton(type: type)
    }
    
    func create() -> UIButton {
        return button
    }
    
    func setTAMIC(_ value: Bool) -> UIButtonBuilder {
        button.translatesAutoresizingMaskIntoConstraints = value
        return self
    }
    
    func setTitle(_ title: String) -> UIButtonBuilder {
        button.setTitle(title, for: [])
        return self
    }
    
    func setFontForTitle(_ font: UIFont) -> UIButtonBuilder {
        button.titleLabel?.font = font
        return self
    }
    
    func setTitleColor(_ color: UIColor) -> UIButtonBuilder {
        button.setTitleColor(color, for: [])
        return self
    }
    
    func setCornerRadius(_ radius: CGFloat) -> UIButtonBuilder {
        button.layer.cornerRadius = radius
        return self
    }
    
    func setRoundedCornerRadius() -> UIButtonBuilder {
        button.layer.cornerRadius = button.frame.size.height / 2
        return self
    }
    
    func setClipsToBounds(_ value: Bool) -> UIButtonBuilder {
        button.clipsToBounds = value
        return self
    }
    
    func setBorderWidth(_ width: CGFloat) -> UIButtonBuilder {
        button.layer.borderWidth = width
        return self
    }
    
    func setBorderColor(_ color: UIColor) -> UIButtonBuilder {
        button.layer.borderColor = color.cgColor
        return self
    }
    
    func setImage(_ image: UIImage?) -> UIButtonBuilder {
        button.setImage(image, for: [])
        return self
    }
    
    func setTintColor(_ color: UIColor) -> UIButtonBuilder {
        button.tintColor = color
        return self
    }
    
    func setBackgroundColor(_ color: UIColor) -> UIButtonBuilder {
        button.backgroundColor = color
        return self
    }
    
    func setSemanticContentAttribute(_ attribute: UISemanticContentAttribute) -> UIButtonBuilder {
        button.semanticContentAttribute = attribute
        return self
    }
    
    func setConfiguration(_ configuration: UIButton.Configuration) -> UIButtonBuilder {
        button.configuration = configuration
        return self
    }
    
    func setContentInsets(_ insets: NSDirectionalEdgeInsets) -> UIButtonBuilder {
        button.configuration?.contentInsets = insets
        return self
    }
    
    func setContentHorizontalAlignment(_ option: UIControl.ContentHorizontalAlignment) -> UIButtonBuilder {
        button.contentHorizontalAlignment = option
        return self
    }
    
    func makeSizeToFit() -> UIButtonBuilder {
        button.sizeToFit()
        return self
    }
    
    func setImagePlacement(_ placement: NSDirectionalRectEdge) -> UIButtonBuilder {
        button.configuration?.imagePlacement = placement
        return self
    }
    
    func setImagePadding(_ padding: CGFloat) -> UIButtonBuilder {
        button.configuration?.imagePadding = padding
        return self
    }
}
