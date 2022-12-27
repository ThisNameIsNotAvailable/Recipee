//
//  RecipeCollectionViewHeader.swift
//  Recipee
//
//  Created by Alex on 26/12/2022.
//

import UIKit

class RecipeCollectionViewHeader: UICollectionReusableView {
    
    static let identifier = "RecipeCollectionViewHeader"
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let disclosureIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .darkGray
        imageView.image = UIImage(systemName: "chevron.right")?.withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 25, weight: .bold)))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    private func layout() {
        addSubview(label)
        addSubview(disclosureIndicator)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            disclosureIndicator.leadingAnchor.constraint(equalTo: label.trailingAnchor),
            disclosureIndicator.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            disclosureIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    func configure(title: String, section: Int) {
        if section == 0 || section == SearchManager.shared.headers.count - 1 {
            disclosureIndicator.isHidden = true
        }
        label.attributedText = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.attributedText = NSAttributedString(string: "")
        disclosureIndicator.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
