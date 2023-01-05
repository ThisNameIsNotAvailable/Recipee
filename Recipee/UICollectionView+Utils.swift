//
//  UICollectionView+Utils.swift
//  Recipee
//
//  Created by Alex on 05/01/2023.
//

import UIKit

extension UICollectionView {
    static func createStandardCollectionView() -> UICollectionView {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { section, _ in
            switch section {
            default:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), repeatingSubitem: item, count: 2)
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), repeatingSubitem: horizontalGroup, count: 1)
                let section = NSCollectionLayoutSection(group: verticalGroup)
                return section
            }
        }))
    }
}
