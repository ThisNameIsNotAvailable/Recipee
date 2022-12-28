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
    
    var isInResultVC = false
    
    public private(set) var buttons = [[Row]]()
    
    public var currentlySelected = [String: Set<String>]()
    
    public var allSelected = Set<String>()
    
    public var viewModels = [[RecipeResponse]](repeating: [RecipeResponse](), count: 8)
    
    private init() {
        viewModels = [[RecipeResponse]](repeating: [RecipeResponse](), count: headers.count)
    }
    
    func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.saveContext()
    }
    
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
