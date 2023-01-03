//
//  StepViewModel.swift
//  Recipee
//
//  Created by Alex on 02/01/2023.
//

import Foundation

struct StepViewModel {
    let description: String
    let numberOfStep: Int
    let ingredients: [IngredientWithoutMeasures]
    let equipment: [Equipment]
    let allStepsNumber: Int
}
