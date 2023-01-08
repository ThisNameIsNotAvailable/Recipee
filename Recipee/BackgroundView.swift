//
//  BackgroubView.swift
//  Recipee
//
//  Created by Alex on 08/01/2023.
//

import UIKit

class BackgroundView: UIView {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "backgroundView")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "There is no data here yet."
        label.font = .appFont(of: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let isImagePresent: Bool
    
    init(labelText: String = "There is no data here yet.", withImage: Bool = true) {
        self.isImagePresent = withImage
        super.init(frame: .zero)
        titleLabel.text = labelText
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        if isImagePresent {
            stackView.addArrangedSubview(imageView)
        }
        stackView.addArrangedSubview(titleLabel)
        
        stackView.sizeToFit()
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
