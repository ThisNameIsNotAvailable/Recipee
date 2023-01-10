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
        
        let nc1 = UINavigationController(rootViewController: SearchViewController())
        let nc2 = UINavigationController(rootViewController: FavouritesViewController())
        let nc3 = UINavigationController(rootViewController: ShoppingListViewController())
        let nc4 = ProfileViewController()
        
        nc1.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "magnifyingglass")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "magnifyingglass")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        nc2.tabBarItem = UITabBarItem(title: "Favourites", image: UIImage(systemName: "heart.fill")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "heart.fill")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        nc3.tabBarItem = UITabBarItem(title: "List", image: UIImage(systemName: "list.bullet")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "list.bullet")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        nc4.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill")?.withTintColor(.element, renderingMode: .alwaysOriginal), selectedImage: UIImage(systemName: "person.fill")?.withTintColor(.selection, renderingMode: .alwaysOriginal))
        
        setViewControllers([nc1, nc2, nc3, nc4], animated: false)
    }
}


