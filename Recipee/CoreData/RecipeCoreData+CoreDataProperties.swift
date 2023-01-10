//
//  RecipeCoreData+CoreDataProperties.swift
//  Recipee
//
//  Created by Alex on 03/01/2023.
//
//

import Foundation
import CoreData


extension RecipeCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeCoreData> {
        return NSFetchRequest<RecipeCoreData>(entityName: "RecipeCoreData")
    }

    @NSManaged public var id: Int64
    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var indredients: NSSet?

}

// MARK: Generated accessors for indredients
extension RecipeCoreData {

    @objc(addIndredientsObject:)
    @NSManaged public func addToIndredients(_ value: IngredientCoreData)

    @objc(removeIndredientsObject:)
    @NSManaged public func removeFromIndredients(_ value: IngredientCoreData)

    @objc(addIndredients:)
    @NSManaged public func addToIndredients(_ values: NSSet)

    @objc(removeIndredients:)
    @NSManaged public func removeFromIndredients(_ values: NSSet)

}

extension RecipeCoreData : Identifiable {

}
