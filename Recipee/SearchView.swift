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
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: [])
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.tintColor = UIColor(red: 0.14, green: 0.22, blue: 0.39, alpha: 1.00)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        searchBar.delegate = self
        layout()
    }
    
    @objc private func cancelTapped() {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            self?.cancelTrailingAnchor?.constant = (self?.cancelButton.frame.size.width ?? 0) + 20
            self?.layoutIfNeeded()
            self?.searchBar.endEditing(true)
            self?.searchBar.searchTextField.text = ""
        }.startAnimation()
        delegate?.searchBarCancelButtonClicked()
    }
    
    private func layout() {
        addSubview(searchBar)
        addSubview(cancelButton)
        cancelButton.sizeToFit()
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -20),
            bottomAnchor.constraint(equalToSystemSpacingBelow: searchBar.bottomAnchor, multiplier: 1),
            
            cancelButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor)
        ])
        cancelTrailingAnchor = cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: cancelButton.frame.size.width + 20)
        cancelTrailingAnchor?.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchView: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            self?.cancelTrailingAnchor?.constant = 0
            self?.layoutIfNeeded()
        }.startAnimation()
        delegate?.searchViewShouldBeginEditing()
        return true
    }
}
