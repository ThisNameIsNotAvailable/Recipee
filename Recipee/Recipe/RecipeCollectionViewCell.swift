//
//  RecipeCollectionViewCell.swift
//  Recipee
//
//  Created by Alex on 26/12/2022.
//

import UIKit
import SDWebImage

class RecipeCollectionViewCell: UICollectionViewCell {
    
    public static let identifier = "RecipeCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "xmark")
        imageView.tintColor = .black
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let recipeLabel: UILabel = {
        let label = UILabel()
        label.text = "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.font = UIFont.appFont(of: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        layout()
    }
    
    private func layout() {
        contentView.addSubview(recipeLabel)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            recipeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            recipeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            recipeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            recipeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(text: String, imageID: Int, fontSize: CGFloat) {
        recipeLabel.font = UIFont.appFont(of: fontSize)
        recipeLabel.text = text
        guard let url = URL(string: "https://spoonacular.com/recipeImages/\(imageID)-480x360.jpg") else {
            return
        }
        imageView.sd_setImage(with: url)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recipeLabel.text = ""
        imageView.image = nil
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
