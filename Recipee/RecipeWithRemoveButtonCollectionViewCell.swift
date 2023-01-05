//
//  RecipeWithRemoveButtonCollectionViewCell.swift
//  Recipee
//
//  Created by Alex on 05/01/2023.
//

import UIKit

protocol RecipeWithRemoveButtonCollectionViewCellDelegate: AnyObject {
    func removeButtonTapped(_ cell: RecipeWithRemoveButtonCollectionViewCell)
}

class RecipeWithRemoveButtonCollectionViewCell: RecipeCollectionViewCell {
    
    weak var delegate: RecipeWithRemoveButtonCollectionViewCellDelegate?
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill")?.withConfiguration(UIImage.SymbolConfiguration(font: .appFont(of: 30))), for: [])
        button.tintColor = .systemRed
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
    }
    
    @objc private func removeTapped() {
        delegate?.removeButtonTapped(self)
    }
    
    override internal func layout() {
        super.layout()
        
        removeButton.sizeToFit()
        contentView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.5),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: removeButton.trailingAnchor, multiplier: 0.5)
        ])
        removeButton.layer.cornerRadius = removeButton.frame.size.height / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
