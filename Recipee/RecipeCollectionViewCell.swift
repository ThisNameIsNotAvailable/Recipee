//
//  RecipeCollectionViewCell.swift
//  Recipee
//
//  Created by Alex on 26/12/2022.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    public static let identifier = "RecipeCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "photo.circle")
        return imageView
    }()
    
    private let recipeLabel: UILabel = {
        let label = UILabel()
        label.text = "recipe"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .element
        layout()
    }
    
    private func layout() {
        contentView.addSubview(recipeLabel)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 2/3),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 2/3),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            recipeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            recipeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            recipeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 5),
            recipeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(text: String) {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
