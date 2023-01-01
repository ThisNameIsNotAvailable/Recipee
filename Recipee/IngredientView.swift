//
//  IngredientView.swift
//  Recipee
//
//  Created by Alex on 01/01/2023.
//

import UIKit

class IngredientView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 50)
    }
    
    private let imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont(of: 12)
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: IngredientViewModel) {
        infoLabel.text = model.info
        guard let imageStr = model.imageURL, let url = URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(imageStr)") else {
            return
        }
        imageView.sd_setImage(with: url)
    }
    
    private func layout() {
        addSubview(imageView)
        addSubview(infoLabel)
        addSubview(divider)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -2),
            
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 105),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        infoLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}
