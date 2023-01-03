//
//  RecipeViewController.swift
//  Recipee
//
//  Created by Alex on 01/01/2023.
//

import UIKit
import SDWebImage
import SafariServices

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
        stack.alignment = .top
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let imageWithButton = ImageViewWithStepButton()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .appFont(of: 26)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sourceButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
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
    private var instructions: [Instruction]!
    private var ingredients: [Ingredient]!
    private var sourceURL = ""
    
    init(id: Int) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(heartTapped))
        view.backgroundColor = .white
        title = "Recipe Info"
        imageWithButton.delegate = self
        sourceButton.addTarget(self, action: #selector(sourceTapped), for: .touchUpInside)
        fetchData()
    }
    
    @objc private func heartTapped() {
        
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
                self?.instructions = recipeInfo.analyzedInstructions
                self?.ingredients = recipeInfo.extendedIngredients
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
                    
                    self?.readyTimeLabel.setTitle("Ready in \(recipeInfo.readyInMinutes) minutes", for: [])
                    self?.readyTimeLabel.sizeToFit()
                    
                    self?.numOfServingsLabel.setTitle("Servings: \(recipeInfo.servings)", for: [])
                    self?.numOfServingsLabel.sizeToFit()
                    
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
                        NSLayoutConstraint.activate([
                            ingredientView.heightAnchor.constraint(equalToConstant: 70)
                        ])
                        self?.ingredientsStackView.addArrangedSubview(ingredientView)
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
        
        dietsScrollView.addSubview(dietsStackView)
        if !dietsStackView.arrangedSubviews.isEmpty {
            stackView.addArrangedSubview(dietsScrollView)
        }
        
        stackView.addArrangedSubview(summaryLabel)
        
        additionalInfoStackView.addArrangedSubview(readyTimeLabel)
        additionalInfoStackView.addArrangedSubview(numOfServingsLabel)
        stackView.addArrangedSubview(additionalInfoStackView)
        
        stackView.addArrangedSubview(ingredientsStackView)
        
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
        let vc = UINavigationController(rootViewController: StepByStepViewController(instructions: instructions, ingredients: ingredients))
        present(vc, animated: true)
    }
}
