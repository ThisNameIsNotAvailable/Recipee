//
//  ExpandableLabel.swift
//  Recipee
//
//  Created by Alex on 01/01/2023.
//

import UIKit


class ExpandableLabel: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = .appFont(of: 18)
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let showMoreLessButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show More", for: [])
        button.setTitleColor(.darkGray, for: [])
        button.titleLabel?.font = .appFont(of: 14)
        return button
    }()
    
    private var isExpanded = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        showMoreLessButton.addTarget(self, action: #selector(didTapShowMoreLess), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapShowMoreLess() {
        if isExpanded {
            label.numberOfLines = 3
            showMoreLessButton.setTitle("Show More", for: [])
            isExpanded = false
        } else {
            label.numberOfLines = 0
            showMoreLessButton.setTitle("Show Less", for: [])
            isExpanded = true
        }
    }
    private var labelBottomConstraint: NSLayoutConstraint?
    private func layout() {
        label.sizeToFit()
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor)
        ])
        labelBottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor)
        labelBottomConstraint?.isActive = true
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    public func setTextforLabel(_ text: String) {
        label.text = text
        if label.isTruncated() {
            showMoreLessButton.sizeToFit()
            label.sizeToFit()
            addSubview(showMoreLessButton)
            labelBottomConstraint?.isActive = false
            NSLayoutConstraint.activate([
                showMoreLessButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 3),
                showMoreLessButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                showMoreLessButton.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            showMoreLessButton.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
    }
}
