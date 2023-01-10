//
//  WhatsInYourFridgeTableViewCell.swift
//  Recipee
//
//  Created by Alex on 09/01/2023.
//

import UIKit

class WhatsInYourFridgeTableViewCell: UITableViewCell {
    
    static let identifier = "WhatsInYourFridgeTableViewCell"
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let fridgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "fridge")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Enter up to 5 products that you have at home to find the recipe you can cook right now!"
        label.font = .appFont(of: 18)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .element
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        stackView.addArrangedSubview(fridgeImageView)
        stackView.addArrangedSubview(label)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            fridgeImageView.widthAnchor.constraint(equalTo: fridgeImageView.heightAnchor),
            
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 0.5),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 0.5),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1)
        ])
        
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        fridgeImageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}
