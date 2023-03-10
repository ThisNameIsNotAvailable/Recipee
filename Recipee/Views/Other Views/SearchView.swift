//
//  SearchView.swift
//  Recipee
//
//  Created by Alex on 27/12/2022.
//

import UIKit

class SearchView: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 1000, height: 500)
    }
    
    private var cancelTrailingAnchor: NSLayoutConstraint?
    private var searchBarTrailingAnchor: NSLayoutConstraint?
    private var refineLeadingAnchor: NSLayoutConstraint?
    private var searchBarLeadingAnchor: NSLayoutConstraint?
    
    weak var delegate: SearchViewDelegate?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Find Recipes...", attributes: [
            .foregroundColor: UIColor.darkGray
        ])
        searchBar.searchTextField.textColor = .black
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButtonBuilder(of: .custom)
            .setImage(UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20, weight: .bold))))
            .setTintColor(.black)
            .setTAMIC(false)
            .create()
        return button
    }()
    
    private let refineButton: UIButton = {
        let button = UIButtonBuilder(of: .system)
            .setTitle("Refine")
            .setFontForTitle(.appFont(of: 18, isBold: true))
            .setTitleColor(.black)
            .setTAMIC(false)
            .create()
        return button
    }()
    
    private let notificationCenter = NotificationCenter.default
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        notificationCenter.addObserver(self, selector: #selector(showRefineButton), name: .showRefine, object: nil)
        notificationCenter.addObserver(self, selector: #selector(hideRefineButton), name: .hideRefine, object: nil)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        searchBar.delegate = self
        refineButton.addTarget(self, action: #selector(refineButtonTapped), for: .touchUpInside)
        layout()
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .showRefine, object: nil)
        notificationCenter.removeObserver(self, name: .hideRefine, object: nil)
    }
    
    @objc private func showRefineButton() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            self?.refineLeadingAnchor?.constant = 0
            self?.searchBarLeadingAnchor?.constant = 8
            self?.layoutIfNeeded()
        }.startAnimation()
    }
    
    @objc private func hideRefineButton() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            self?.refineLeadingAnchor?.constant = -((self?.refineButton.frame.size.width ?? 0) + 20)
            self?.searchBarLeadingAnchor?.constant = 20
            self?.layoutIfNeeded()
        }.startAnimation()
    }
    
    func showCancelButton() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            self?.cancelTrailingAnchor?.constant = 0
            self?.searchBarTrailingAnchor?.constant = -8
            self?.layoutIfNeeded()
        }.startAnimation()
    }
    
    @objc private func refineButtonTapped() {
        delegate?.refineButtonTapped()
    }
    
    @objc private func cancelTapped() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            self?.cancelTrailingAnchor?.constant = (self?.cancelButton.frame.size.width ?? 0) + 20
            self?.searchBarTrailingAnchor?.constant = -20
            self?.hideRefineButton()
            self?.layoutIfNeeded()
            self?.searchBar.endEditing(true)
            self?.searchBar.searchTextField.text = ""
        }.startAnimation()
        delegate?.searchBarCancelButtonClicked()
    }
    
    private func layout() {
        addSubview(searchBar)
        addSubview(cancelButton)
        addSubview(refineButton)
        cancelButton.sizeToFit()
        refineButton.sizeToFit()
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalToSystemSpacingBelow: searchBar.bottomAnchor, multiplier: 1),
            
            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            refineButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor)
        ])
        cancelTrailingAnchor = cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: cancelButton.frame.size.width + 20)
        cancelTrailingAnchor?.isActive = true
        
        searchBarTrailingAnchor = searchBar.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -20)
        searchBarTrailingAnchor?.isActive = true
        
        refineLeadingAnchor = refineButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -(refineButton.frame.size.width + 20))
        refineLeadingAnchor?.isActive = true
        
        searchBarLeadingAnchor = searchBar.leadingAnchor.constraint(equalTo: refineButton.trailingAnchor, constant: 20)
        searchBarLeadingAnchor?.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchView: UISearchBarDelegate {
    
    @discardableResult
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            self?.showCancelButton()
            self?.layoutIfNeeded()
        }.startAnimation()
        delegate?.searchViewShouldBeginEditing()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        SearchManager.shared.currentQuery = searchText
        delegate?.searchBarTextDidChange()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.searchTextField.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        SearchManager.shared.isInResultVC = true
        SearchManager.shared.currentQuery = query
        delegate?.searchButtonClicked(with: query)
    }
}
