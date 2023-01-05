//
//  IngredientCollectionViewCell.swift
//  Recipee
//
//  Created by Alex on 03/01/2023.
//

import UIKit

class IngredientCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "IngredientCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(of: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 3)
        ])
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func configure(with model: IngredientViewModel) {
        nameLabel.text = model.info.capitalized
        guard let imageStr = model.imageURL, let url = URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(imageStr)") else {
            return
        }
        imageView.sd_setImage(with: url)
    }
}
