//
//  IngredientCoreData+CoreDataProperties.swift
//  Recipee
//
//  Created by Alex on 03/01/2023.
//
//

import Foundation
import CoreData


extension IngredientCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientCoreData> {
        return NSFetchRequest<IngredientCoreData>(entityName: "IngredientCoreData")
    }

    @NSManaged public var id: Int64
    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var recipes: NSSet?

}

// MARK: Generated accessors for recipes
extension IngredientCoreData {

    @objc(addRecipesObject:)
    @NSManaged public func addToRecipes(_ value: RecipeCoreData)

    @objc(removeRecipesObject:)
    @NSManaged public func removeFromRecipes(_ value: RecipeCoreData)

    @objc(addRecipes:)
    @NSManaged public func addToRecipes(_ values: NSSet)

    @objc(removeRecipes:)
    @NSManaged public func removeFromRecipes(_ values: NSSet)

}

extension IngredientCoreData : Identifiable {

}
