//
//  RecipeViewController.swift
//  Recipee
//
//  Created by Alex on 01/01/2023.
//

import UIKit
import SDWebImage

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
        stack.alignment = .top
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .appFont(of: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        stack.alignment = .leading
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let summaryLabel = ExpandableLabel()
    
    private let additionalInfoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        return stack
    }()
    
    private let readyTimeLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = .appFont(of: 16)
        label.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        label.setTitleColor(.black, for: [])
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .secondaryBackground
        label.clipsToBounds = true
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let numOfServingsLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = .appFont(of: 16)
        label.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        label.setTitleColor(.black, for: [])
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .secondaryBackground
        label.clipsToBounds = true
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
    
    private let id: Int
    
    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Recipe Info"
        layout()
//        716429 324694
        APICaller.shared.getRecipeInfo(id: id) { [weak self] res in
            switch res {
            case .failure(let error):
                print(error)
            case .success(let recipeInfo):
                DispatchQueue.main.async {
                    self?.titleLabel.text = recipeInfo.title
                    self?.summaryLabel.setTextforLabel(recipeInfo.summary.htmlToString)
                    if let imageURL = URL(string: "https://spoonacular.com/recipeImages/\(recipeInfo.id)-480x360.jpg") {
                        self?.imageView.sd_setImage(with: imageURL)
                    }
                    self?.readyTimeLabel.setTitle("Ready in \(recipeInfo.readyInMinutes) minutes", for: [])
                    self?.numOfServingsLabel.setTitle("Servings: \(recipeInfo.servings)", for: [])
                    for dietTitle in recipeInfo.diets {
                        let label = SearchManager.shared.createButton(with: dietTitle)
                        label.backgroundColor = .secondaryBackground
                        label.isUserInteractionEnabled = false
                        label.translatesAutoresizingMaskIntoConstraints = false
                        label.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
                        label.tintColor = .black
                        self?.dietsStackView.addArrangedSubview(label)
                    }
                    
                    for ingredient in recipeInfo.extendedIngredients {
                        let ingredientView = IngredientView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
                        let labelText = "\(ingredient.name.capitalized) - \(ingredient.measures.metric.amount) \(ingredient.measures.metric.unitShort)"
                        ingredientView.configure(with: IngredientViewModel(imageURL: ingredient.image, info: labelText))
                        self?.ingredientsStackView.addArrangedSubview(ingredientView)
                    }
                    
                    self?.layout()
                }
            }
        }
    }
    
    private func layout() {
        stackView.addArrangedSubview(imageView)
        
        dietsScrollView.addSubview(dietsStackView)
        if !dietsStackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(dietsScrollView)
        }
        
        stackView.addArrangedSubview(titleLabel)
        
        stackView.addArrangedSubview(summaryLabel)
        
        additionalInfoStackView.addArrangedSubview(readyTimeLabel)
        additionalInfoStackView.addArrangedSubview(numOfServingsLabel)
        stackView.addArrangedSubview(additionalInfoStackView)
        
        stackView.addArrangedSubview(ingredientsStackView)
        
        scrollView.addSubview(stackView)
        
        
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            scrollView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: scrollView.trailingAnchor, multiplier: 1),
            scrollView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
            view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollView.bottomAnchor, multiplier: 1),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
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
