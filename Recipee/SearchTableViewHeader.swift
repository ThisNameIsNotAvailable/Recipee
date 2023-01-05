//
//  SearchTableViewHeader.swift
//  Recipee
//
//  Created by Alex on 27/12/2022.
//

import UIKit

class SearchTableViewHeader: UITableViewHeaderFooterView {
    static let identifier = "SearchTableViewHeader"
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.appFont(of: 24)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    private func layout() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            label.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1)
        ])
    }
    
    func configure(title: String) {
        label.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
