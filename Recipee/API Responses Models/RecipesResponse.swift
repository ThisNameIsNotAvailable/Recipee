//
//  RecipeResponse.swift
//  Recipee
//
//  Created by Alex on 28/12/2022.
//

import Foundation


struct RecipesResponse: Codable {
    let recipes: [RecipeResponse]
}

struct RecipeResponse: Codable {
    let id: Int
    let title: String
    let image: String?
}
