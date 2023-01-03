//
//  EquipmentView.swift
//  Recipee
//
//  Created by Alex on 02/01/2023.
//

import UIKit

class EquipmentView: UIView {
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Equipment"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont(of: 18)
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(headerLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            scrollView.topAnchor.constraint(equalToSystemSpacingBelow: headerLabel.bottomAnchor, multiplier: 1),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        let width = stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        width.priority = UILayoutPriority(250)
        width.isActive = true
        
    }
    
    func configure(with model: [EquipmentModel]) {
        for equipment in model {
            let equipmentCell = EquipmentCellView()
            equipmentCell.configure(with: equipment)
            NSLayoutConstraint.activate([
                equipmentCell.widthAnchor.constraint(equalToConstant: 70),
                equipmentCell.heightAnchor.constraint(equalToConstant: 110)
            ])
            stackView.addArrangedSubview(equipmentCell)
        }
    }
}
