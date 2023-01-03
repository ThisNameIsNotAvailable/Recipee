//
//  StepView.swift
//  Recipee
//
//  Created by Alex on 02/01/2023.
//

import UIKit

class StepView: UIView {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .top
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        return stack
    }()
    
    private let numOfStepLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(of: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel = ExpandableLabel()
    
    private let equipmentsView = EquipmentView()
    
    private let model: StepViewModel
    
    init(model: StepViewModel) {
        self.model = model
        super.init(frame: .zero)
        backgroundColor = .background
        translatesAutoresizingMaskIntoConstraints = false
        layout()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(numOfStepLabel)
        descriptionLabel.sizeToFit()
        stackView.addArrangedSubview(descriptionLabel)
        stackView.sizeToFit()
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            numOfStepLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            numOfStepLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: numOfStepLabel.trailingAnchor, multiplier: 1),
            
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: numOfStepLabel.bottomAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1)
        ])
        
        numOfStepLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func configure() {
        numOfStepLabel.text = "\(model.numberOfStep) of \(model.allStepsNumber)"
        descriptionLabel.setTextforLabel(model.description)
        
        if !model.equipment.isEmpty {
            equipmentsView.configure(with: model.equipment.compactMap({ equipment in
                EquipmentViewModel(name: equipment.name, imageURL: "https://spoonacular.com/cdn/equipment_100x100/\(equipment.image)")
            }))
            stackView.addArrangedSubview(equipmentsView)
        }
    }
}
