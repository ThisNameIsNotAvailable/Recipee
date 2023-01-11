//
//  FoldersWithRemoveViewController.swift
//  Recipee
//
//  Created by Alex on 08/01/2023.
//

import UIKit
import FirebaseAuth

class FoldersWithRemoveViewController: FoldersViewController {
    
    private let removeButton: UIButton = {
        let button = UIButtonBuilder(of: .system)
            .setTitle("Remove From Favourites")
            .setFontForTitle(.appFont(of: 20))
            .setTitleColor(.black)
            .setBackgroundColor(.element)
            .setBorderColor(.black)
            .setBorderWidth(1)
            .setCornerRadius(8)
            .setClipsToBounds(true)
            .setTAMIC(false)
            .create()
        return button
    }()
    
    private let recipe: RecipeInfoResponse
    
    init(recipe: RecipeInfoResponse) {
        self.recipe = recipe
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        layout()
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
    }
    
    @objc private func updateTableView() {
        tableView.reloadData()
    }
    
    @objc private func removeTapped() {
        guard let currentUserEmail = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        DatabaseManager.shared.removeRecipe(with: recipe.id, from: "favourites", for: currentUserEmail) { success in
            if success {
                NotificationCenter.default.post(name: .updateHeartButton, object: nil)
                NotificationCenter.default.post(name: .updateCollectionView, object: nil)
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    private func layout() {
        view.addSubview(tableView)
        removeButton.sizeToFit()
        view.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: removeButton.topAnchor),
            
            removeButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: removeButton.trailingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: removeButton.bottomAnchor, multiplier: 1)
        ])
    }
}

extension FoldersWithRemoveViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        DatabaseManager.shared.addRecipe(RecipeResponse(id: recipe.id, title: recipe.title, image: "https://spoonacular.com/recipeImages/\(recipe.id)-480x360.jpg"), to: folders[indexPath.row].title, for: email) { [weak self] success in
            self?.dismiss(animated: true)
            if success {
                NotificationCustom.shared.post(name: .updateFolders)
            }
        }
    }
}
