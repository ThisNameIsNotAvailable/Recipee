//
//  RecipeViewController.swift
//  Recipee
//
//  Created by Alex on 01/01/2023.
//

import UIKit
import SDWebImage
import SafariServices
import FirebaseAuth

protocol ImageViewWithStepButtonDelegate: AnyObject {
    func stepButtonTapped()
}

class RecipeViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let imageWithButton = ImageViewWithStepButton()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .appFont(of: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sourceButton: UIButton = {
        let button = UIButtonBuilder(of: .custom)
            .setContentHorizontalAlignment(.leading)
            .setTitle("Show More")
            .setTitleColor(.black)
            .setTAMIC(false)
            .create()
        return button
    }()
    
    private let dietsScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let dietsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let summaryLabel = ExpandableLabel()
    
    private let additionalInfoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        return stack
    }()
    
    private let readyTimeLabel: UIButton = {
        let label = UIButtonBuilder(of: .system)
            .setTitleColor(.black)
            .setTAMIC(false)
            .setBackgroundColor(.secondaryBackground)
            .setClipsToBounds(true)
            .setBorderWidth(1)
            .setBorderColor(.black)
            .setConfiguration(.plain())
            .setContentInsets(NSDirectionalEdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
            .create()
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let numOfServingsLabel: UIButton = {
        let label = UIButtonBuilder(of: .system)
            .setTitleColor(.black)
            .setTAMIC(false)
            .setBackgroundColor(.secondaryBackground)
            .setClipsToBounds(true)
            .setBorderWidth(1)
            .setBorderColor(.black)
            .setConfiguration(.plain())
            .setContentInsets(NSDirectionalEdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
            .create()
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let ingredientsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .top
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let collectionView: UICollectionView = {
        let collection = DynamicHeightCollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { section, _ in
            switch section {
            default:
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                header.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 2)
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(220)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(220)), repeatingSubitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [header]
                return section
            }
        }))
        collection.clipsToBounds = true
        collection.layer.cornerRadius = 8
        collection.widthAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        collection.heightAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .background
        collection.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        collection.register(RecipeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecipeCollectionViewHeader.identifier)
        return collection
    }()
    
    private let id: Int
    private var recipeInfo: RecipeInfoResponse!
    private var sourceURL = ""
    
    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var heartButton: UIBarButtonItem!
    private var listButton: UIBarButtonItem!
    
    private var recipes = [RecipeResponse]()
    
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        listButton = UIBarButtonItem(image: UIImage(systemName: "text.justify"), style: .plain, target: self, action: #selector(listTapped))
        heartButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(heartTapped))
        heartButton.tintColor = .systemRed
        if RecipeManager.shared.isRecipeAlreadyAdded(id: id) {
            listButton.image = UIImage(systemName: "text.badge.checkmark")
            listButton.tag = 1
        }
        
        updateHeartButton()
        
        configureCollectionView()
        
        
        navigationItem.rightBarButtonItems = [heartButton, listButton]
        view.backgroundColor = .white
        title = "Recipe Info"
        imageWithButton.delegate = self
        sourceButton.addTarget(self, action: #selector(sourceTapped), for: .touchUpInside)
        
        fetchData()
        
        notificationCenter.addObserver(self, selector: #selector(updateHeartButton), name: .updateHeartButton, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateListButton), name: .updateListButton, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .updateHeartButton, object: nil)
        notificationCenter.removeObserver(self, name: .updateListButton, object: nil)
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc private func updateHeartButton() {
        if let email = FirebaseAuth.Auth.auth().currentUser?.email {
            DatabaseManager.shared.isInFavourites(id: id, email: email, completion: { [weak self] present in
                if present {
                    DispatchQueue.main.async {
                        self?.heartButton.image = UIImage(systemName: "heart.fill")
                        self?.heartButton.tag = 1
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.heartButton.image = UIImage(systemName: "heart")
                        self?.heartButton.tag = 0
                    }
                }
            })
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.heartButton.image = UIImage(systemName: "heart")
                self?.heartButton.tag = 0
            }
        }
    }
    
    @objc private func updateListButton() {
        if RecipeManager.shared.isRecipeAlreadyAdded(id: id) {
            listButton.image = UIImage(systemName: "text.badge.checkmark")
            listButton.tag = 1
        } else {
            listButton.image = UIImage(systemName: "text.justify")
            listButton.tag = 0
        }
    }
    
    @objc private func listTapped() {
        if listButton.tag == 1 {
            listButton.image = UIImage(systemName: "text.justify")
            listButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            listButton.tag = 0
            RecipeManager.shared.deleteRecipe(id: id)
        } else {
            listButton.image = UIImage(systemName: "text.badge.checkmark")
            listButton.tag = 1
            RecipeManager.shared.save(recipe: recipeInfo)
        }
        NotificationCenter.default.post(name: .updateTableView, object: nil)
    }
    
    @objc private func heartTapped() {
        if heartButton.tag == 1 {
            let vc = FoldersWithRemoveViewController(recipe: recipeInfo)
            present(vc, animated: true)
        } else {
            guard let currentUserEmail = FirebaseAuth.Auth.auth().currentUser?.email else {
                let vc = LoginViewController()
                present(vc, animated: true)
                return
            }
            let recipe = RecipeResponse(id: id, title: recipeInfo.title, image: "https://spoonacular.com/recipeImages/\(id)-480x360.jpg")
            DatabaseManager.shared.addRecipe(recipe, to: "favourites", for: currentUserEmail) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.heartButton.image = UIImage(systemName: "heart.fill")
                    }
                    self?.heartButton.tag = 1
                    NotificationCenter.default.post(name: .updateCollectionView, object: nil)
                }
            }
        }
    }
    
    @objc private func sourceTapped() {
        guard let url = URL(string: sourceURL) else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func fetchData() {
        APICaller.shared.getRecipeInfo(id: id) { [weak self] res in
            switch res {
            case .failure(let error):
                print(error)
            case .success(let recipeInfo):
                self?.recipeInfo = recipeInfo
                DispatchQueue.main.async {
                    self?.titleLabel.text = recipeInfo.title
                    
                    let title = NSMutableAttributedString(string: "By ", attributes: [
                        .font: UIFont.systemFont(ofSize: 14)
                    ])
                    title.append(NSAttributedString(string: "\(recipeInfo.sourceName)", attributes: [
                        .foregroundColor: UIColor.selection,
                        .font: UIFont.systemFont(ofSize: 14, weight: .bold)
                    ]))
                    self?.sourceButton.setAttributedTitle(title, for: [])
                    self?.sourceURL = recipeInfo.sourceUrl
                    
                    self?.summaryLabel.setTextforLabel(recipeInfo.summary.htmlToString)
                    
                    if let imageURL = URL(string: "https://spoonacular.com/recipeImages/\(recipeInfo.id)-480x360.jpg") {
                        self?.imageWithButton.configure(with: imageURL)
                        if !recipeInfo.analyzedInstructions.isEmpty {
                            self?.imageWithButton.makeButtonVisible()
                        }
                    }
                    
                    self?.readyTimeLabel.setAttributedTitle(NSAttributedString(string: "Ready in \(recipeInfo.readyInMinutes) minutes", attributes: [
                                .font: UIFont.appFont(of: 16),
                                .foregroundColor: UIColor.black]), for: [])
                    self?.readyTimeLabel.sizeToFit()
                    
                    self?.numOfServingsLabel.setAttributedTitle(NSAttributedString(string: "Servings: \(recipeInfo.servings)", attributes: [
                        .font: UIFont.appFont(of: 16),
                        .foregroundColor: UIColor.black]), for: [])
                    self?.numOfServingsLabel.sizeToFit()
                    
                    for dietTitle in recipeInfo.diets {
                        let label = SearchManager.shared.createButton(with: dietTitle)
                        label.backgroundColor = .secondaryBackground
                        label.isUserInteractionEnabled = false
                        label.translatesAutoresizingMaskIntoConstraints = false
                        label.tintColor = .black
                        self?.dietsStackView.addArrangedSubview(label)
                    }
                    
                    for ingredient in recipeInfo.extendedIngredients {
                        let ingredientView = IngredientView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
                        let labelText = "\(ingredient.name.capitalized) - \(ingredient.measures.metric.amount) \(ingredient.measures.metric.unitShort)"
                        ingredientView.configure(with: IngredientViewModel(imageURL: ingredient.image, info: labelText))
                        NSLayoutConstraint.activate([
                            ingredientView.heightAnchor.constraint(equalToConstant: 70)
                        ])
                        self?.ingredientsStackView.addArrangedSubview(ingredientView)
                    }
                    
                    guard let id = self?.id else {
                        return
                    }
                    
                    APICaller.shared.getSimilar(to: id) { [weak self] res in
                        switch res {
                        case .success(let recipes):
                            self?.recipes = recipes.compactMap({ recipe in
                                RecipeResponse(id: recipe.id, title: recipe.title, image: "https://spoonacular.com/recipeImages/\(recipe.id)-480x360.jpg")
                            })
                            DispatchQueue.main.async {
                                self?.collectionView.reloadData()
                                self?.view.layoutIfNeeded()
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                    self?.layout()
                }
            }
        }
    }
    
    private func layout() {
        stackView.addArrangedSubview(titleLabel)
        
        sourceButton.sizeToFit()
        stackView.addArrangedSubview(sourceButton)
        
        stackView.addArrangedSubview(imageWithButton)
        
        dietsStackView.sizeToFit()
        dietsScrollView.addSubview(dietsStackView)
        if !dietsStackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(dietsScrollView)
        }
        
        stackView.addArrangedSubview(summaryLabel)
        
        additionalInfoStackView.sizeToFit()
        additionalInfoStackView.addArrangedSubview(readyTimeLabel)
        additionalInfoStackView.addArrangedSubview(numOfServingsLabel)
        stackView.addArrangedSubview(additionalInfoStackView)
        
        stackView.addArrangedSubview(ingredientsStackView)
        
        stackView.addArrangedSubview(collectionView)
        
        scrollView.addSubview(stackView)
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: scrollView.trailingAnchor, multiplier: 1),
            scrollView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollView.bottomAnchor, multiplier: 1),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: scrollView.topAnchor, multiplier: 1),
            scrollView.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            dietsStackView.leadingAnchor.constraint(equalTo: dietsScrollView.leadingAnchor),
            dietsStackView.trailingAnchor.constraint(equalTo: dietsScrollView.trailingAnchor),
            dietsStackView.topAnchor.constraint(equalTo: dietsScrollView.topAnchor),
            dietsStackView.bottomAnchor.constraint(equalTo: dietsScrollView.bottomAnchor),
            dietsStackView.heightAnchor.constraint(equalTo: dietsScrollView.frameLayoutGuide.heightAnchor)
        ])
        
        let width = dietsStackView.widthAnchor.constraint(equalTo: dietsScrollView.frameLayoutGuide.widthAnchor)
        width.priority = UILayoutPriority(250)
        width.isActive = true
        
        readyTimeLabel.layer.cornerRadius = readyTimeLabel.frame.size.height / 2
        numOfServingsLabel.layer.cornerRadius = numOfServingsLabel.frame.size.height / 2
    }
}

extension RecipeViewController: ImageViewWithStepButtonDelegate {
    func stepButtonTapped() {
        let vc = UINavigationController(rootViewController: StepByStepViewController(instructions: recipeInfo.analyzedInstructions, ingredients: recipeInfo.extendedIngredients))
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension RecipeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as? RecipeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: recipes[indexPath.row].title, imageID: recipes[indexPath.row].id, fontSize: 20)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecipeCollectionViewHeader.identifier, for: indexPath) as? RecipeCollectionViewHeader else {
            return UICollectionReusableView()
        }

        header.configure(title: "Similar Recipes", section: 0)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = RecipeViewController(id: recipes[indexPath.row].id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
