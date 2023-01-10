//
//  ListViewModel.swift
//  Recipee
//
//  Created by Alex on 04/01/2023.
//

import Foundation

struct ListViewModel {
    let id: Int
    let title: String
    let imageURL: String
    let ingredients: [IngredientViewModel]
}
