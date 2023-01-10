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
    func searchButtonClicked(with query: String)
    func searchBarTextDidChange()
}

protocol OptionCollectionViewCellDelegate: AnyObject {
    func optionButtonClicked(with option: String, shouldAddButton: Bool)
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
        stack.distribution = .fillProportionally
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        return stack
    }()
    
    private let optionsTableView: UITableView = {
        let tv = OptionsTableView(frame: .zero, style: .grouped)
        tv.register(WhatsInYourFridgeTableViewCell.self, forCellReuseIdentifier: WhatsInYourFridgeTableViewCell.identifier)
        tv.isHidden = true
        return tv
    }()
    
    private let resultCollectionView: UICollectionView = {
        let collection = UICollectionView.createStandardCollectionView()
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .background
        collection.showsVerticalScrollIndicator = false
        collection.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: RecipeCollectionViewCell.identifier)
        collection.isHidden = true
        collection.infiniteScrollDirection = .vertical
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
    
    private var feedIsShown = false {
        didSet {
            if feedIsShown {
                scrollView.isHidden = true
                resultCollectionView.isHidden = true
                optionsTableView.isHidden = true
                feedCollectionView.isHidden = false
                SearchManager.shared.isInResultVC = false
            }
        }
    }
    
    private var resultsIsShown = false {
        didSet {
            if resultsIsShown {
                scrollView.isHidden = false
                resultCollectionView.isHidden = false
                optionsTableView.isHidden = true
                feedCollectionView.isHidden = true
                SearchManager.shared.isInResultVC = true
            }
        }
    }
    
    private var optionsIsShown = false {
        didSet {
            if optionsIsShown {
                optionsTableView.isHidden = false
                resultCollectionView.isHidden = true
                scrollView.isHidden = true
                feedCollectionView.isHidden = true
                SearchManager.shared.isInResultVC = false
            }
        }
    }
    
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
        for _ in 0..<SearchManager.shared.headers.count {
            group.enter()
        }
        if SearchManager.shared.needToChangeMealOfTheDay {
            APICaller.shared.getRandomRecipes(number: 1) { res in
                defer {
                    group.leave()
                }
                switch res {
                case .success(let recipes):
                    SearchManager.shared.feedViewModels[0] = recipes
                    DispatchQueue.main.async {
                        SearchManager.shared.deleteAll()
                        SearchManager.shared.save(recipe: recipes.first!)
                    }
                    UserDefaults.standard.set(Date(), forKey: "current_date")
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            if let recipe = SearchManager.shared.getRecipeOfTheDay() {
                SearchManager.shared.feedViewModels[0] = [recipe]
            }
            group.leave()
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
        
        group.notify(queue: .main) { [weak self] in
            self?.feedCollectionView.reloadData()
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
        
        resultCollectionView.addInfiniteScroll { collection in
            guard var options = SearchManager.shared.getOptionsForURL(), !options.isEmpty else {
                DispatchQueue.main.async {
                    collection.finishInfiniteScroll()
                }
                return
            }
            options += "&offset=\(SearchManager.shared.offsetForResult)"
            APICaller.shared.getRecipesWithOptions(options: options) { res in
                switch res {
                case .failure(let error):
                    print(error)
                case .success(let recipes):
                    SearchManager.shared.offsetForResult += 20
                    recipes.forEach { recipe in
                        DispatchQueue.main.async {
                            SearchManager.shared.resultsViewModels.append(recipe)
                            collection.insertItems(at: [IndexPath(item: SearchManager.shared.resultsViewModels.count - 1, section: 0)])
                        }
                    }
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
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        
        feedCollectionView.keyboardDismissMode = .onDrag
        resultCollectionView.keyboardDismissMode = .onDrag
        optionsTableView.keyboardDismissMode = .onDrag
        
    }
    
    private func layout() {
        view.addSubview(feedCollectionView)
        view.addSubview(resultCollectionView)
        view.addSubview(optionsTableView)
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
            stackView.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            resultCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultCollectionView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 5),
            resultCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            resultCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1),
            
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            optionsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addButtonToStackView(with option: String) {
        if option.starts(with: "Under") {
            stackView.arrangedSubviews.forEach { view in
                guard let button = view as? UIButton, let title = button.titleLabel?.text else {
                    return
                }
                
                if title.starts(with: "Under") {
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
}

//MARK: - Actions
extension SearchViewController {
    @objc private func didDeselectOption(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else {
            return
        }
        for v in SearchManager.shared.currentlySelected {
            if v.value.contains(title) {
                SearchManager.shared.currentlySelected[v.key]?.remove(title)
                break
            }
        }
        updateResultCollectionView()
        sender.removeFromSuperview()
        stackView.removeArrangedSubview(sender)
    }
}

//MARK: - SearchViewDelegate
extension SearchViewController: SearchViewDelegate {
    func searchButtonClicked(with query: String) {
        resultsIsShown = true
        searchView.endEditing(true)
        updateResultCollectionView()
    }
    
    func searchViewShouldBeginEditing() {
        if !SearchManager.shared.isInResultVC {
            optionsIsShown = true
        }
    }
    
    func searchBarCancelButtonClicked() {
        feedIsShown = true
        SearchManager.shared.currentQuery = ""
        SearchManager.shared.currentlySelected.removeAll()
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func refineButtonTapped() {
        let vc = OptionsViewController()
        let nc = UINavigationController(rootViewController: vc)
        vc.completion = { [weak self] title in
            DispatchQueue.main.async {
                self?.updateResultCollectionView()
                self?.addButtonToStackView(with: title)
                self?.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
        }
        present(nc, animated: true)
    }
    
    func searchBarTextDidChange() {
        resultsIsShown = true
        updateResultCollectionView()
    }
}

//MARK: - OptionCollectionViewCellDelegate
extension SearchViewController: OptionCollectionViewCellDelegate {
    func optionButtonClicked(with option: String, shouldAddButton: Bool) {
        resultsIsShown = true
        searchView.endEditing(true)
        if shouldAddButton {
            addButtonToStackView(with: option)
            updateResultCollectionView()
        }
    }
}

//MARK: - Collection View Delegate
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCollectionViewCell.identifier, for: indexPath) as? RecipeCollectionViewCell else {
            return UICollectionViewCell()
        }
        if collectionView == feedCollectionView {
            let fontSize: CGFloat
            if indexPath.section == 0 {
                fontSize = 24
            } else if indexPath.section == 7 {
                fontSize = 20
            } else {
                fontSize = 16
            }
            cell.configure(text: SearchManager.shared.feedViewModels[indexPath.section][indexPath.row].title, imageID: SearchManager.shared.feedViewModels[indexPath.section][indexPath.row].id, fontSize: fontSize)
        } else if collectionView == resultCollectionView {
            cell.configure(text: SearchManager.shared.resultsViewModels[indexPath.row].title, imageID: SearchManager.shared.resultsViewModels[indexPath.row].id, fontSize: 20)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.backgroundView = nil
        if collectionView == resultCollectionView {
            return 1
        }
        if SearchManager.shared.feedViewModels.contains(where: { recipes in
            recipes.count == 0
        }) {
            collectionView.backgroundView = BackgroundView(labelText: "Something went wrong. Try to reload the page.")
            return 0
        }
        return SearchManager.shared.feedViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == resultCollectionView {
            if SearchManager.shared.resultsViewModels.count == 0 {
                collectionView.backgroundView = BackgroundView(labelText: "Wait till the data is loaded or try to reload the page.")
            } else {
                collectionView.backgroundView = nil
            }
            return SearchManager.shared.resultsViewModels.count
        }
        if SearchManager.shared.feedViewModels[section].count == 0 {
            collectionView.backgroundView = BackgroundView()
        } else {
            collectionView.backgroundView = nil
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
            let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
            header.addGestureRecognizer(tap)
            if (1...2).contains(indexPath.section) {
                header.tag = 1
            } else if (3...5).contains(indexPath.section) {
                header.tag = 3
            } else if 6 == indexPath.section {
                header.tag = 0
            }
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == resultCollectionView {
            let vc = RecipeViewController(id: SearchManager.shared.resultsViewModels[indexPath.row].id)
            navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == feedCollectionView {
            let vc = RecipeViewController(id: SearchManager.shared.feedViewModels[indexPath.section][indexPath.row].id)
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc private func headerTapped(_ sender: UITapGestureRecognizer) {
        guard let header = sender.view as? RecipeCollectionViewHeader,
              let labelText = header.label.text,
              labelText != SearchManager.shared.headers[0],
              labelText != SearchManager.shared.headers[SearchManager.shared.headers.count - 1] else {
            return
        }
        if labelText.starts(with: "Under") {
            SearchManager.shared.currentlySelected["Difficulty"] = [labelText]
        } else {
            if let _ = SearchManager.shared.currentlySelected[SearchManager.shared.headersForSearch[header.tag]] {
                SearchManager.shared.currentlySelected[SearchManager.shared.headersForSearch[header.tag]]?.insert(labelText)
            } else {
                SearchManager.shared.currentlySelected[SearchManager.shared.headersForSearch[header.tag]] = [labelText]
            }
        }
        optionButtonClicked(with: labelText, shouldAddButton: true)
        searchView.showCancelButton()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = optionsTableView.dequeueReusableCell(withIdentifier: WhatsInYourFridgeTableViewCell.identifier, for: indexPath) as? WhatsInYourFridgeTableViewCell else {
                return UITableViewCell()
            }
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = optionsTableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.identifier, for: indexPath) as? OptionsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: indexPath.section - 1)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SearchManager.shared.headersForSearch.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchTableViewHeader.identifier) as? SearchTableViewHeader else {
            return nil
        }
        
        header.configure(title: SearchManager.shared.headersForSearch[section])
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = EnterProductsViewController()
            let nc = UINavigationController(rootViewController: vc)
            nc.modalPresentationStyle = .fullScreen
            vc.onButtonTap = { [weak self] ingredients in
                self?.dismiss(animated: true)
                APICaller.shared.getRecipesByIgredients(ingredients) { res in
                    switch res {
                    case .success(let recipes):
                        SearchManager.shared.resultsViewModels = recipes
                        DispatchQueue.main.async {
                            self?.resultsIsShown = true
                            NotificationCenter.default.post(name: .hideRefine, object: nil)
                            self?.resultCollectionView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            present(nc, animated: true)
        }
    }
}

//MARK: - View Creation
extension SearchViewController {
    
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
        let button = UIButtonBuilder(of: .custom)
            .setTitle(option)
            .setTitleColor(.black)
            .setFontForTitle(.appFont(of: 18))
            .setImage(UIImage(systemName: "xmark.circle"))
            .setTintColor(.black)
            .setConfiguration(.plain())
            .setContentInsets(NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
            .setImagePlacement(.trailing)
            .setImagePadding(5)
            .setBackgroundColor(.element)
            .makeSizeToFit()
            .setRoundedCornerRadius()
            .setClipsToBounds(true)
            .setTAMIC(false)
            .setBorderWidth(1)
            .setBorderColor(.black)
            .create()
        button.addTarget(self, action: #selector(didDeselectOption(_:)), for: .touchUpInside)
        return button
    }
}

//MARK: - Result Collection View Update
extension SearchViewController {
    func updateResultCollectionView() {
        guard let optionsForURL = SearchManager.shared.getOptionsForURL(), !optionsForURL.isEmpty else {
            return
        }
        SearchManager.shared.offsetForResult = 20
        APICaller.shared.getRecipesWithOptions(options: optionsForURL) { [weak self] res in
            switch res {
            case .failure(let error):
                print(error)
            case .success(let recipes):
                SearchManager.shared.resultsViewModels = recipes
                if recipes.isEmpty {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .hideRefine, object: nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .showRefine, object: nil)
                    }
                }
                DispatchQueue.main.async {
                    self?.resultCollectionView.reloadData()
                }
            }
        }
    }
}
