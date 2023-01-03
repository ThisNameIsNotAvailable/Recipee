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
    
    private let collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { section, _ in
            switch section {
            default:
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)), repeatingSubitem: item, count: 3)
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(180)), subitems: [verticalGroup])
                let section = NSCollectionLayoutSection(group: horizontalGroup)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [header]
                return section
            }
        }))
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsHorizontalScrollIndicator = false
        collection.register(IngredientCollectionViewCell.self, forCellWithReuseIdentifier: IngredientCollectionViewCell.identifier)
        collection.register(IngredientCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: IngredientCollectionViewHeader.identifier)
        collection.backgroundColor = .background
        return collection
    }()
    
    private let model: StepViewModel
    
    init(model: StepViewModel) {
        self.model = model
        super.init(frame: .zero)
        backgroundColor = .background
        translatesAutoresizingMaskIntoConstraints = false
        layout()
        configure()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(numOfStepLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            numOfStepLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            numOfStepLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: numOfStepLabel.trailingAnchor, multiplier: 1),
            
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: numOfStepLabel.bottomAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1)
        ])
    
    }
    
    private func configure() {
        numOfStepLabel.text = "\(model.numberOfStep) of \(model.allStepsNumber)"
        descriptionLabel.setTextforLabel(model.description) 
        
        if !model.equipment.isEmpty {
            equipmentsView.configure(with: model.equipment.compactMap({ equipment in
                EquipmentModel(name: equipment.name, imageURL: "https://spoonacular.com/cdn/equipment_100x100/\(equipment.image)")
            }))
            stackView.addArrangedSubview(equipmentsView)
        }
        
        if !model.ingredients.isEmpty {
            stackView.addArrangedSubview(collectionView)
            NSLayoutConstraint.activate([
                collectionView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
            ])
        }
    }
}

extension StepView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.ingredients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCollectionViewCell.identifier, for: indexPath) as? IngredientCollectionViewCell else {
            return UICollectionViewCell()
        }
        let ingredientModel = IngredientViewModel(imageURL: model.ingredients[indexPath.row].image, info: model.ingredients[indexPath.row].name)
        cell.configure(with: ingredientModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: IngredientCollectionViewHeader.identifier, for: indexPath) as? IngredientCollectionViewHeader else {
                return UICollectionReusableView()
            }
            header.configure(title: "Ingredients")
            return header
        default:
            return UICollectionReusableView()
        }
    }
}
