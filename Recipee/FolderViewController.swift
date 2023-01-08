//
//  FolderViewController.swift
//  Recipee
//
//  Created by Alex on 08/01/2023.
//

import UIKit
import FirebaseAuth

class FolderViewController: UIViewController {
    
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
    
    private let folderName: String
    private var recipes = [RecipeResponse]()
    
    init(folderName: String) {
        self.folderName = folderName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        collectionView.delegate = self
        collectionView.dataSource = self
        layout()
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        navigationController?.navigationBar.tintColor = .black
        DatabaseManager.shared.getFolder(with: folderName, for: email) { [weak self] res in
            switch res {
            case .success(let recipes):
                self?.recipes = recipes
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
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
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
}

extension FolderViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recipes.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeWithRemoveButtonCollectionViewCell.identifier, for: indexPath) as? RecipeWithRemoveButtonCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.configure(text: recipes[indexPath.row].title, imageID: recipes[indexPath.row].id, fontSize: 20)
        return cell
    }
}

extension FolderViewController: RecipeWithRemoveButtonCollectionViewCellDelegate {
    func removeButtonTapped(_ cell: RecipeWithRemoveButtonCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
        let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        DatabaseManager.shared.removeRecipe(with: recipes[indexPath.row].id, from: folderName, for: email) { [weak self] success in
            if success {
                self?.recipes.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self?.collectionView.deleteItems(at: [indexPath])
                }
                NotificationCenter.default.post(name: .updateFolders, object: nil)
            }
        }
    }
}
