//
//  RecipeManager.swift
//  Recipee
//
//  Created by Alex on 03/01/2023.
//

import UIKit
import CoreData

class RecipeManager {
    
    static let shared = RecipeManager()
    
    private init(){}
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func save(recipe: RecipeInfoResponse) {
        guard let context = getContext() else {
            return
        }
        let r = RecipeCoreData(context: context)
        r.id = Int64(recipe.id)
        r.title = recipe.title
        r.imageURL = "https://spoonacular.com/recipeImages/\(recipe.id)-480x360.jpg"
        for ingredient in recipe.extendedIngredients {
            let ingredientCD = IngredientCoreData(context: context)
            ingredientCD.id = Int64(ingredient.id)
            ingredientCD.title = "\(ingredient.name) - \(ingredient.measures.metric.amount) \(ingredient.measures.metric.unitShort)"
            ingredientCD.imageURL = "https://spoonacular.com/cdn/ingredients_100x100/\(ingredient.image ?? "")"
            r.addToIndredients(ingredientCD)
        }
        RecipeManager.shared.save()
    }
    
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.saveContext()
    }
    
    private func getRecipeWithID(id: Int) -> RecipeCoreData? {
        let fetchRequest: NSFetchRequest<RecipeCoreData> = RecipeCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id LIKE %@", "\(id)")
        fetchRequest.fetchLimit = 1
        
        guard let context = getContext() else {
            return nil
        }
        
        do {
            if let object = try context.fetch(fetchRequest).first {
                return object
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func getAllRecipes() -> [RecipeResponse] {
        let request: NSFetchRequest<RecipeCoreData> = RecipeCoreData.fetchRequest()
        var fetchedRecipes: [RecipeCoreData] = []
        do {
            guard let context = getContext() else {
                return []
            }
            fetchedRecipes = try context.fetch(request)
        } catch let error {
            print("Error fetching singers \(error)")
        }
        return fetchedRecipes.compactMap { recipeCD in
            RecipeResponse(id: Int(recipeCD.id), title: recipeCD.title ?? "", image: recipeCD.imageURL)
        }
    }
    
    func isRecipeAlreadyAdded(id: Int) -> Bool {
        getRecipeWithID(id: id) != nil
    }
    
    func deleteRecipe(id: Int) {
        guard let objectToDelete = getRecipeWithID(id: id), let context = getContext() else {
            return
        }
        if let ingredients = objectToDelete.indredients {
            for ingredient in ingredients {
                context.delete(ingredient as! IngredientCoreData)
            }
        }
        context.delete(objectToDelete)
        save()
    }
    
    func deleteAll() {
        var fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RecipeCoreData")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        do {
            guard let context = getContext() else {
                return
            }
            try appDelegate.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch {
            print(error.localizedDescription)
        }
        
        fetchRequest = NSFetchRequest(entityName: "IngredientCoreData")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        do {
            guard let context = getContext() else {
                return
            }
            try appDelegate.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch {
            print(error.localizedDescription)
        }
    }
}
