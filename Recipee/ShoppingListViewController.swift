//
//  ShoppingListViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit

class ShoppingListViewController: UIViewController {

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private var recipes = [RecipeResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        tableView.delegate = self
        tableView.dataSource = self
        layout()
        
        updateTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: NSNotification.Name("update tablewView"), object: nil)
    }
    
    @objc private func updateTableView() {
        recipes = RecipeManager.shared.getAllRecipes()
        tableView.reloadData()
    }
    
    private func layout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = recipes[indexPath.row].title
        return cell
    }
}
