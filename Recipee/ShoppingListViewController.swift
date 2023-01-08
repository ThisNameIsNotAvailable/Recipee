//
//  ShoppingListViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit

class ShoppingListViewController: UIViewController {

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
        tv.separatorColor = .clear
        tv.alwaysBounceVertical = false
        tv.backgroundColor = .background
        return tv
    }()
    
    private let collectionView: UICollectionView = {
        let collection = UICollectionView.createStandardCollectionView()
        collection.showsVerticalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .background
        collection.isHidden = true
        collection.alwaysBounceVertical = false
        collection.register(RecipeWithRemoveButtonCollectionViewCell.self, forCellWithReuseIdentifier: RecipeWithRemoveButtonCollectionViewCell.identifier)
        return collection
    }()
    
    private var recipes = [ListViewModel]()
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        title = "Shopping List"
        configureTableView()
        configureCollectionView()
        layout()
        
        updateTableView()
        
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItem?.tag = 0
        
        notificationCenter.addObserver(self, selector: #selector(updateTableView), name: .updateTableView, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .updateTableView, object: nil)
    }
    
    @objc private func editTapped() {
        guard let tag = navigationItem.rightBarButtonItem?.tag else {
            return
        }
        if tag == 0 {
            collectionView.isHidden = false
            tableView.isHidden = true
            navigationItem.rightBarButtonItem?.title = "Cancel"
            navigationItem.rightBarButtonItem?.tag = 1
        } else {
            collectionView.isHidden = true
            tableView.isHidden = false
            navigationItem.rightBarButtonItem?.title = "Edit"
            navigationItem.rightBarButtonItem?.tag = 0
        }
        
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 600
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc private func updateTableView() {
        recipes = RecipeManager.shared.getAllRecipes()
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    private func layout() {
        view.addSubview(tableView)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: ListViewModel(id: recipes[indexPath.row].id, title: recipes[indexPath.row].title, imageURL: recipes[indexPath.row].imageURL, ingredients: recipes[indexPath.row].ingredients))
        cell.delegate = self
        return cell
    }
}

extension ShoppingListViewController: ListTableViewCellDelegate {
    func recipeTapped(with id: Int) {
        let vc = RecipeViewController(id: id)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteCell(_ cell: ListTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        RecipeManager.shared.deleteRecipe(id: recipes[indexPath.row].id)
        recipes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        collectionView.deleteItems(at: [indexPath])
        NotificationCenter.default.post(name: .updateListButton, object: nil)
    }
}

extension ShoppingListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeWithRemoveButtonCollectionViewCell.identifier, for: indexPath) as? RecipeWithRemoveButtonCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: recipes[indexPath.row].title, imageID: recipes[indexPath.row].id, fontSize: 20)
        cell.delegate = self
        return cell
    }
}

extension ShoppingListViewController: RecipeWithRemoveButtonCollectionViewCellDelegate {
    func removeButtonTapped(_ cell: RecipeWithRemoveButtonCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        RecipeManager.shared.deleteRecipe(id: recipes[indexPath.row].id)
        recipes.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        tableView.deleteRows(at: [indexPath], with: .automatic)
        NotificationCenter.default.post(name: .updateListButton, object: nil)
    }
}
