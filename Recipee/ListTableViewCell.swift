//
//  ListTableViewCell.swift
//  Recipee
//
//  Created by Alex on 04/01/2023.
//

import UIKit
import SDWebImage

protocol ListTableViewCellDelegate: AnyObject {
    func recipeTapped(with id: Int)
    func deleteCell(_ cell: ListTableViewCell)
}

class ListTableViewCell: UITableViewCell {
    
    static let identifier = "ListTableViewCell"
    
    weak var delegate: ListTableViewCellDelegate?
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .appFont(of: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove From Shopping List", for: [])
        button.titleLabel?.font = .appFont(of: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .selection
        button.setTitleColor(.black, for: [])
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
    }()
    
    private var recipeID: Int!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layout()
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recipeTapped)))
        recipeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recipeTapped)))
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func recipeTapped() {
        delegate?.recipeTapped(with: recipeID)
    }
    
    @objc private func removeTapped() {
        delegate?.deleteCell(self)
    }
    
    private func layout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(recipeImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            recipeImageView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            recipeImageView.heightAnchor.constraint(equalToConstant: 50),
            recipeImageView.widthAnchor.constraint(equalTo: recipeImageView.heightAnchor),
            
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: recipeImageView.trailingAnchor, multiplier: 1),
            titleLabel.centerYAnchor.constraint(equalTo: recipeImageView.centerYAnchor),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: recipeImageView.bottomAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            
            removeButton.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            removeButton.topAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: removeButton.trailingAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: removeButton.bottomAnchor, multiplier: 1)
        ])
        
        recipeImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func configure(with model: ListViewModel) {
        recipeID = model.id
        titleLabel.text = model.title
        for ingredient in model.ingredients {
            let itemView = ItemView()
            itemView.configure(with: ingredient.info)
            stackView.addArrangedSubview(itemView)
        }
        guard let url = URL(string: model.imageURL) else {
            return
        }
        recipeImageView.sd_setImage(with: url)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recipeID = nil
        stackView.arrangedSubviews.forEach { v in
            v.removeFromSuperview()
        }
        titleLabel.text = nil
        recipeImageView.image = nil
    }
}
