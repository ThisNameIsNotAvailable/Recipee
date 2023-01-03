//
//  ImageViewWithStepButton.swift
//  Recipee
//
//  Created by Alex on 02/01/2023.
//

import UIKit
import SDWebImage

class ImageViewWithStepButton: UIView {
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    weak var delegate: ImageViewWithStepButtonDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let stepButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setTitle("Step By Step", for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .element
        button.clipsToBounds = true
        button.isHidden = true
        button.titleLabel?.font = .appFont(of: 16)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        button.setImage(UIImage(systemName: "chevron.right")?.withConfiguration(UIImage.SymbolConfiguration(font: .appFont(of: 12))), for: [])
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        layout()
        stepButton.addTarget(self, action: #selector(stepButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(imageView)
        addSubview(stepButton)
        stepButton.sizeToFit()
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            trailingAnchor.constraint(equalToSystemSpacingAfter: stepButton.trailingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: stepButton.bottomAnchor, multiplier: 1)
        ])
        
        stepButton.layer.cornerRadius = stepButton.frame.size.height / 2
    }
    
    func configure(with imageURL: URL) {
        imageView.sd_setImage(with: imageURL)
    }
    
    func makeButtonVisible() {
        stepButton.isHidden = false
    }
    
    @objc private func stepButtonTapped() {
        delegate?.stepButtonTapped()
    }
}
