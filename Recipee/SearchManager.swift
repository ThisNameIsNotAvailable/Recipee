//
//  SearchManager.swift
//  Recipee
//
//  Created by Alex on 27/12/2022.
//

import UIKit
import CoreData

class SearchManager {
    
    public static let shared = SearchManager()
    
    var needToChange: Bool {
        if let date = UserDefaults.standard.value(forKey: "current_date") as? Date {
            let calendar = Calendar.current
            let dateWritten = calendar.dateComponents([.day, .month, .year], from: date)
            let dateCurrent = calendar.dateComponents([.day, .month, .year], from: Date())
            if dateWritten.date == dateCurrent.date && dateCurrent.month == dateWritten.month && dateWritten.year == dateCurrent.year {
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    public let headers =  ["Meal Of The Day", "Breakfast", "Drinks", "American cuisine", "Chinese cuisine", "Middle Eastern cuisine", "Under 30 minutes", "You may like"]
    
    public let headersForSearch = ["Difficulty", "Meal", "Diet", "Cuisine"]
    
    private let options = [
        [
            "Under 60 Minutes",  "Under 30 Minutes",  "Under 15 Minutes",  "Under 45 Minutes"
        ],
        [
            "Dessert", "Appetizer", "Breakfast", "Drink", "Main course", "Salad"
        ],
        [
            "Gluten Free", "Ketogenic", "Vegetarian", "Vegan", "Pescetarian", "Lacto-Vegetarian", "Ovo-Vegetarian", "Paleo",
            "Primal", "Low FODMAP", "Whole30"
        ],
        [
            "African",
            "American",
            "British",
            "Cajun",
            "Caribbean",
            "Chinese",
            "Eastern European",
            "European",
            "French",
            "German",
            "Greek",
            "Indian",
            "Irish",
            "Italian",
            "Japanese",
            "Jewish",
            "Korean",
            "Latin American",
            "Mediterranean",
            "Mexican",
            "Middle Eastern",
            "Nordic",
            "Southern",
            "Spanish",
            "Thai",
            "Vietnamese"
        ]
    ]
    
    var isInResultVC = false {
        didSet {
            if isInResultVC {
                NotificationCenter.default.post(name: NSNotification.Name("Showed Result VC"), object: nil)
            }
        }
    }
    
    public private(set) var buttons = [[Row]]()
    
    public var currentlySelected = [String: Set<String>]()
    public var translateHeaderToAPIField = [
        "Difficulty": "maxReadyTime",
        "Meal": "type",
        "Diet": "diet",
        "Cuisine": "cuisine"
    ]
    
    public var currentQuery = ""
    
    public var feedViewModels = [[RecipeResponse]]()
    public var resultsViewModels = [RecipeResponse]()
    
    private init() {
        feedViewModels = [[RecipeResponse]](repeating: [RecipeResponse](), count: headers.count)
    }
    
    func getOptionsForURL() -> String? {
        var str = ""
        currentlySelected.forEach { title in
            if !title.value.isEmpty {
                if title.key == "Difficulty" {
                    str += "&\(translateHeaderToAPIField[title.key]!)="
                    title.value.forEach { option in
                        let time = option.components(separatedBy: " ")[1]
                        str += "\(time),"
                    }
                    str.removeLast()
                }else {
                    str += "&\(translateHeaderToAPIField[title.key]!)="
                    title.value.forEach { option in
                        str += "\(option),"
                    }
                    str.removeLast()
                }
            }
        }
        if !currentQuery.isEmpty {
            str += "&query=\(currentQuery)"
        }
        return str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func save(recipe: RecipeResponse) {
        guard let context = getContext() else {
            return
        }
        let r = Recipe(context: context)
        r.id = Int64(recipe.id)
        r.title = recipe.title
        r.imageURL = recipe.image
        SearchManager.shared.save()
    }
    
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.saveContext()
    }
    
    func getRecipeOfTheDay() -> RecipeResponse? {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        do {
            guard let context = getContext() else {
                return nil
            }
            let recipes = try context.fetch(fetchRequest)
            guard let recipeCD = recipes.first, let title = recipeCD.title, let imageURL = recipeCD.imageURL else {
                return nil
            }
            let recipe = RecipeResponse(id: Int(recipeCD.id), title: title, image: imageURL)
            return recipe
        } catch {
            print("Unable to Fetch Recipe, (\(error))")
        }
        return nil
    }
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Recipe")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
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
    
    class Row {
        var sum: CGFloat = 0
        var titles = [String]()
    }
    
    public func sortForLabels(screenWidth: CGFloat) {
        let button = UIButton(type: .system)
        for option in options {
            var rows = [Row]()
            for el in option {
                button.setTitle(el, for: [])
                button.titleLabel?.font = .systemFont(ofSize: 18)
                button.sizeToFit()
                button.layer.cornerRadius = button.frame.size.height / 2
                let width = button.frame.size.width + 26
                var isFound = false
                for row in rows {
                    if row.sum + width < screenWidth - 8 {
                        isFound = true
                        row.sum += width
                        row.titles.append(el)
                        break
                    }
                }
                if !isFound {
                    let row = Row()
                    row.sum = width
                    row.titles.append(el)
                    rows.append(row)
                }
            }
            rows.sort { row1, row2 in
                row1.sum > row2.sum
            }
            buttons.append(rows)
        }
    }
}
