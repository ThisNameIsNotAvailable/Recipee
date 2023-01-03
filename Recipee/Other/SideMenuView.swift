//
//  SideMenuViewController.swift
//  Recipee
//
//  Created by Alex on 03/01/2023.
//

import UIKit

protocol SideMenuDelegate: AnyObject {
    func hideMenu()
}

class SideMenuView: UIView {
    
    weak var delegate: SideMenuDelegate?
    
    private let collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { section, _ in
            switch section {
            default:
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60)), repeatingSubitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: verticalGroup)
                section.boundarySupplementaryItems = [header]
                return section
            }
        }))
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.showsVerticalScrollIndicator = false
        collection.register(IngredientCollectionViewCell.self, forCellWithReuseIdentifier: IngredientCollectionViewCell.identifier)
        collection.register(IngredientCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: IngredientCollectionViewHeader.identifier)
        collection.backgroundColor = .secondaryBackground
        collection.alwaysBounceVertical = false
        return collection
    }()
    
    private let ingredients: [Ingredient]
    
    init(ingredients: [Ingredient]) {
        self.ingredients = ingredients
        super.init(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2/3)
        ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != collectionView {
            delegate?.hideMenu()
        }
    }
}

extension SideMenuView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IngredientCollectionViewCell.identifier, for: indexPath) as? IngredientCollectionViewCell else {
            return UICollectionViewCell()
        }
        let ingredientModel = IngredientViewModel(imageURL: ingredients[indexPath.row].image, info: "\(ingredients[indexPath.row].name) - \(ingredients[indexPath.row].measures.metric.amount) \(ingredients[indexPath.row].measures.metric.unitShort)")
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
