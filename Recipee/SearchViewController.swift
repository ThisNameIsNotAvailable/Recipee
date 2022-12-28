//
//  SearchViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit
import UIScrollView_InfiniteScroll
import CoreData

protocol SearchViewDelegate: AnyObject {
    func searchViewShouldBeginEditing()
    func searchBarCancelButtonClicked()
    func refineButtonTapped()
}

protocol OptionCollectionViewCellDelegate: AnyObject {
    func optionButtonClicked(with option: String)
}

class SearchViewController: UIViewController {
    
    private var searchView: SearchView!
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.isHidden = true
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        return stack
    }()
    
    private let searchTableView: UITableView = {
        let tv = OptionsTableView(frame: .zero, style: .grouped)
        tv.isHidden = true
        return tv
    }()
    
    private let resultCollectionView: UICollectionView = {
        let collection = SearchViewController.createResultCollectionView()
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .background
        collection.showsVerticalScrollIndicator = false
        collection.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        collection.isHidden = true
        return collection
    }()
    
    private let feedCollectionView: UICollectionView = {
        let collection = SearchViewController.createFeedCollectionView()
        collection.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        collection.register(RecipeCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecipeCollectionViewHeader.identifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .background
        collection.showsVerticalScrollIndicator = false
        collection.infiniteScrollDirection = .vertical
        return collection
    }()
    
    private var recommendations = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .background
            appearance.shadowColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        fetchData()
        configureCollectionViews()
        configureSearchView()
        layout()
    }
    
    private func fetchData() {
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        group.enter()
        if SearchManager.shared.needToChange {
            APICaller.shared.getRandomRecipes(number: 1) { res in
                defer {
                    group.leave()
                }
                switch res {
                case .success(let recipes):
                    SearchManager.shared.feedViewModels[0] = recipes
                    DispatchQueue.main.async {
                        guard let context = SearchManager.shared.getContext(),
                              let id = recipes.first?.id,
                              let title = recipes.first?.title else {
                            return
                        }
                        let r = Recipe(context: context)
                        r.id = Int64(id)
                        r.title = title
                        r.imageURL = recipes.first?.image ?? ""
                        SearchManager.shared.save()
                    }
                    UserDefaults.standard.set(Date(), forKey: "current_date")
                    DispatchQueue.main.async {
                        self.feedCollectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            DispatchQueue.main.async {
                do {
                    guard let context = SearchManager.shared.getContext() else {
                        return
                    }
                    let recipes = try context.fetch(fetchRequest)
                    guard let recipeCD = recipes.first, let title = recipeCD.title, let imageURL = recipeCD.imageURL else {
                        return
                    }
                    let recipe = RecipeResponse(id: Int(recipeCD.id), title: title, image: imageURL)
                    SearchManager.shared.feedViewModels[0] = [recipe]
                    self.feedCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                } catch {
                    print("Unable to Fetch Recipe, (\(error))")
                }
            }
            
        }
        APICaller.shared.getMealType(type: "breakfast") { res in
            defer {
                group.leave()
            }
            switch res {
            case .success(let recipes):
                SearchManager.shared.feedViewModels[1] = recipes
            case .failure(let error):
                print(error)
            }
        }
        
        APICaller.shared.getMealType(type: "drink") { res in
            defer {
                group.leave()
            }
            switch res {
            case .success(let recipes):
                SearchManager.shared.feedViewModels[2] = recipes
            case .failure(let error):
                print(error)
            }
        }
        
        APICaller.shared.getCusine(cuisine: "american") { res in
            defer {
                group.leave()
            }
            switch res {
            case .success(let recipes):
                SearchManager.shared.feedViewModels[3] = recipes
            case .failure(let error):
                print(error)
            }
        }
        
        APICaller.shared.getCusine(cuisine: "Chinese") { res in
            defer {
                group.leave()
            }
            switch res {
            case .success(let recipes):
                SearchManager.shared.feedViewModels[4] = recipes
            case .failure(let error):
                print(error)
            }
        }
        
        APICaller.shared.getCusine(cuisine: "middle%20eastern") { res in
            defer {
                group.leave()
            }
            switch res {
            case .success(let recipes):
                SearchManager.shared.feedViewModels[5] = recipes
            case .failure(let error):
                print(error)
            }
        }
        
        APICaller.shared.getMaxReadyTime(maxReadyTime: 30) { res in
            defer {
                group.leave()
            }
            switch res {
            case .success(let recipes):
                SearchManager.shared.feedViewModels[6] = recipes
            case .failure(let error):
                print(error)
            }
        }
        
        APICaller.shared.getRandomRecipes(number: 20) { res in
            defer {
                group.leave()
            }
            switch res {
            case .success(let recipes):
                SearchManager.shared.feedViewModels[7] = recipes
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) {
            self.feedCollectionView.reloadData()
        }
    }
    
    private func configureSearchView() {
        SearchManager.shared.sortForLabels(screenWidth: view.frame.size.width)
        searchView = SearchView(frame: navigationController!.navigationBar.frame)
        searchView.delegate = self
        navigationItem.titleView = searchView
    }
    
    private func configureCollectionViews() {
        feedCollectionView.addInfiniteScroll { collection in
            APICaller.shared.getRandomRecipes(number: 20) { res in
                switch res {
                case .success(let recipes):
                    recipes.forEach { recipe in
                        DispatchQueue.main.async {
                            SearchManager.shared.feedViewModels[7].append(recipe)
                            collection.insertItems(at: [IndexPath(item: SearchManager.shared.feedViewModels[7].count - 1, section: 7)])
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                DispatchQueue.main.async {
                    collection.finishInfiniteScroll()
                }
            }
        }
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        feedCollectionView.keyboardDismissMode = .onDrag
        resultCollectionView.keyboardDismissMode = .onDrag
        searchTableView.keyboardDismissMode = .onDrag
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.estimatedRowHeight = 600
    }
    
    private func layout() {
        view.addSubview(feedCollectionView)
        view.addSubview(resultCollectionView)
        view.addSubview(searchTableView)
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            feedCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            feedCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            feedCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            feedCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            resultCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultCollectionView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 5),
            resultCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addButtonToStackView(with option: String) {
        if !SearchManager.shared.allSelected.insert(option).inserted {
            return
        }
        
        if option.starts(with: "Under") {
            stackView.arrangedSubviews.forEach { view in
                guard let button = view as? UIButton, let title = button.titleLabel?.text else {
                    return
                }
                
                if title.starts(with: "Under") {
                    SearchManager.shared.allSelected.remove(title)
                    for v in SearchManager.shared.currentlySelected {
                        if v.value.contains(title) {
                            SearchManager.shared.currentlySelected[v.key]?.remove(title)
                            break
                        }
                    }
                    view.removeFromSuperview()
                }
            }
        }
        
        stackView.insertArrangedSubview(createButton(with: option), at: 0)
    }
    
    @objc private func didDeselectOption(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else {
            return
        }
        SearchManager.shared.allSelected.remove(title)
        for v in SearchManager.shared.currentlySelected {
            if v.value.contains(title) {
                SearchManager.shared.currentlySelected[v.key]?.remove(title)
                break
            }
        }
        sender.removeFromSuperview()
        stackView.removeArrangedSubview(sender)
    }
}

extension SearchViewController: SearchViewDelegate {
    func searchViewShouldBeginEditing() {
        if !SearchManager.shared.isInResultVC {
            feedCollectionView.isHidden = true
            searchTableView.isHidden = false
        }
    }
    
    func searchBarCancelButtonClicked() {
        feedCollectionView.isHidden = false
        searchTableView.isHidden = true
        resultCollectionView.isHidden = true
        scrollView.isHidden = true
        SearchManager.shared.isInResultVC = false
        SearchManager.shared.currentlySelected.removeAll()
        SearchManager.shared.allSelected.removeAll()
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func refineButtonTapped() {
        let vc = OptionsViewController()
        let nc = UINavigationController(rootViewController: vc)
        vc.completion = { [weak self] title in
            DispatchQueue.main.async {
                self?.addButtonToStackView(with: title)
                self?.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
        }
        present(nc, animated: true)
    }
}

extension SearchViewController: OptionCollectionViewCellDelegate {
    func optionButtonClicked(with option: String) {
        searchTableView.isHidden = true
        resultCollectionView.isHidden = false
        searchView.endEditing(true)
        scrollView.isHidden = false
        addButtonToStackView(with: option)
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as? RecipeCollectionViewCell else {
            return UICollectionViewCell()
        }
        //refactor
        let fontSize: CGFloat
        if indexPath.section == 0 {
            fontSize = 24
        } else if indexPath.section == 7 {
            fontSize = 20
        } else {
            fontSize = 14
        }
        if collectionView == feedCollectionView {
            cell.configure(text: SearchManager.shared.feedViewModels[indexPath.section][indexPath.row].title, imageID: SearchManager.shared.feedViewModels[indexPath.section][indexPath.row].id, fontSize: fontSize)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == resultCollectionView {
            return 1
        }
        return SearchManager.shared.feedViewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == resultCollectionView {
            return 8
        }
        return SearchManager.shared.feedViewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecipeCollectionViewHeader.identifier, for: indexPath) as? RecipeCollectionViewHeader else {
                return UICollectionReusableView()
            }
            header.configure(title: SearchManager.shared.headers[indexPath.section], section: indexPath.section)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = searchTableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.identifier, for: indexPath) as? OptionsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: indexPath.section)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SearchManager.shared.buttons.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchTableViewHeader.identifier) as? SearchTableViewHeader else {
            return nil
        }
        
        header.configure(title: SearchManager.shared.headersForSearch[section])
        return header
    }
}

//MARK: - View Creation
extension SearchViewController {
    private static func createResultCollectionView() -> UICollectionView {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { section, _ in
            switch section {
            default:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), repeatingSubitem: item, count: 2)
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), repeatingSubitem: horizontalGroup, count: 1)
                let section = NSCollectionLayoutSection(group: verticalGroup)
                return section
            }
        }))
    }
    
    private static func createFeedCollectionView() -> UICollectionView {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { section, _ in
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            header.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 2)
            switch section {
            case 0:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.2)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.2)), repeatingSubitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [header]
                return section
            case 1...6:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(220)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(220)), repeatingSubitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [header]
                return section
            case 7:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 5, bottom: 5, trailing: 5)
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.7)), repeatingSubitem: item, count: 2)
                let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), repeatingSubitem: horizontalGroup, count: 1)
                let section = NSCollectionLayoutSection(group: verticalGroup)
                section.boundarySupplementaryItems = [header]
                return section
            default:
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(300)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), repeatingSubitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                return section
            }
        }))
    }
    
    private func createButton(with option: String) -> UIButton {
        let button = UIButton()
        button.setTitle(option, for: [])
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .black
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitleColor(.black, for: [])
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        button.backgroundColor = .element
        button.sizeToFit()
        button.layer.cornerRadius = button.frame.size.height / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didDeselectOption(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
