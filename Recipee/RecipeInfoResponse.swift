//
//  RecipeInfoResponse.swift
//  Recipee
//
//  Created by Alex on 01/01/2023.
//

import Foundation

struct MetricMeasure: Codable {
    let amount: Double
    let unitShort: String
}

struct Measure: Codable {
    let metric: MetricMeasure
}

struct Ingredient: Codable {
    let name: String
    let image: String?
    let measures: Measure
}

struct Equipment: Codable {
    let name: String
    let image: String
}

struct Step: Codable {
    let step: String
    let number: Int
    let equipment: [Equipment]
}

struct Instruction: Codable {
    let name: String
    let steps: [Step]
}

struct RecipeInfoResponse: Codable {
    let extendedIngredients: [Ingredient]
    let title: String // X
    let readyInMinutes: Int // X
    let servings: Int // X
    let sourceUrl: String
    let id: Int
    let summary: String // X
    let diets: [String] // X
    let analyzedInstructions: [Instruction]
}
