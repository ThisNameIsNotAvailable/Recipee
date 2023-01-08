//
//  FavouritesViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit
import FirebaseAuth

class FavouritesViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let collection = UICollectionView.createStandardCollectionView()
        collection.showsVerticalScrollIndicator = false
        collection.alwaysBounceVertical = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .background
        collection.register(RecipeWithRemoveButtonCollectionViewCell.self, forCellWithReuseIdentifier: RecipeWithRemoveButtonCollectionViewCell.identifier)
        collection.keyboardDismissMode = .onDrag
        return collection
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Find Recipes...", attributes: [
            .foregroundColor: UIColor.darkGray
        ])
        searchBar.searchTextField.textColor = .black
        searchBar.tintColor = .black
        return searchBar
    }()
    
    private var recipes = [RecipeResponse]()
    private var filteredRecipes = [RecipeResponse]()
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        title = "Favourites"
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        layout()
        fetchData()
        notificationCenter.addObserver(self, selector: #selector(fetchData), name: .updateCollectionView, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .updateCollectionView, object: nil)
    }
    
    @objc func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    
    private func layout() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func fetchData() {
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        DatabaseManager.shared.getFolder(with: "favourites", for: email) { [weak self] res in
            switch res {
            case .failure(let error):
                print(error)
            case .success(let recipes):
                self?.recipes = recipes
                self?.filteredRecipes = recipes
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

extension FavouritesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeWithRemoveButtonCollectionViewCell.identifier, for: indexPath) as? RecipeWithRemoveButtonCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: filteredRecipes[indexPath.row].title, imageID: filteredRecipes[indexPath.row].id, fontSize: 20)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = RecipeViewController(id: filteredRecipes[indexPath.row].id)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FavouritesViewController: RecipeWithRemoveButtonCollectionViewCellDelegate {
    func removeButtonTapped(_ cell: RecipeWithRemoveButtonCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell), let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        DatabaseManager.shared.removeRecipe(with: filteredRecipes[indexPath.row].id, from: "favourites", for: email) { [weak self] success in
            if success {
                if let removed = self?.filteredRecipes.remove(at: indexPath.row)  {
                    if let index = self?.recipes.firstIndex(where: { recipe in
                        recipe.id == removed.id
                    }) {
                        self?.recipes.remove(at: index)
                    }
                }
                NotificationCenter.default.post(name: .updateHeartButton, object: nil)
                DispatchQueue.main.async {
                    self?.collectionView.deleteItems(at: [indexPath])
                }
            }
        }
    }
}

extension FavouritesViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.searchTextField.text = ""
        filteredRecipes = recipes
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            filteredRecipes = recipes
            collectionView.reloadSections(IndexSet(integer: 0))
            return
        }
        filteredRecipes = recipes.filter({ recipe in
            recipe.title.contains(searchText)
        })
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}
