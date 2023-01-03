//
//  ViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .secondaryBackground
            
            let tabItemAppearance = UITabBarItemAppearance()
            tabItemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.element
            ]
            tabItemAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.selection
            ]
            
            appearance.stackedLayoutAppearance = tabItemAppearance
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
//        var instructions = [Instruction]()
//        for _ in 0...5 {
//            var steps = [Step]()
//            for i in 0...4 {
//                var equipments = [Equipment]()
//                var ingredients = [Ingredient]()
//                for _ in 0...10 {
//                    equipments.append(Equipment(name: "something", image: "slow-cooker.jpg"))
//                    ingredients.append(Ingredient(name: "name", image: "", measures: Measure(metric: MetricMeasure(amount: 1, unitShort: "tbs"))))
//                }
//                steps.append(Step(step: "Combine the bourbon and sugar in a small saucepan and cook over high heat until reduced to 3 tablespoons, remove and let cool.", number: i+1, equipment: equipments, ingredients: ingredients))
//            }
//            let instr = Instruction(name: "qwer", steps: steps)
//            instructions.append(instr)
//        }
        
        let nc1 = UINavigationController(rootViewController: SearchViewController())
        let nc2 = UINavigationController(rootViewController: FavouritesViewController())
        let nc3 = UINavigationController(rootViewController: ShoppingListViewController())
        let nc4 = UINavigationController(rootViewController: ProfileViewController())
        
        nc1.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "magnifyingglass")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "magnifyingglass")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        nc2.tabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "heart.fill")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "heart.fill")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        nc3.tabBarItem = UITabBarItem(title: "List", image: UIImage(systemName: "list.bullet")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "list.bullet")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        nc4.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "person.fill")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        
        setViewControllers([nc1, nc2, nc3, nc4], animated: false)
    }
}


