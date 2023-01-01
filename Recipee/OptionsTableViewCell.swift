//
//  OptionsCollectionViewCell.swift
//  Recipee
//
//  Created by Alex on 27/12/2022.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    static let identifier = "OptionsCollectionViewCell"
    weak var delegate: OptionCollectionViewCellDelegate?
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
        backgroundColor = .background
    }
    
    private func layout() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -4),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with section: Int) {
        for row in SearchManager.shared.buttons[section] {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 6
            stackView.alignment = .leading
            stackView.translatesAutoresizingMaskIntoConstraints = false
            for title in row.titles {
                let button = SearchManager.shared.createButton(with: title)
                button.tintColor = .black
                button.contentEdgeInsets = UIEdgeInsets(top: 8, left: SearchManager.shared.optionButtonPadding, bottom: 8, right: SearchManager.shared.optionButtonPadding)
                button.tag = section
                button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
                button.backgroundColor = .element
                button.clipsToBounds = true
                button.translatesAutoresizingMaskIntoConstraints = false
                stackView.addArrangedSubview(button)
            }
            self.stackView.addArrangedSubview(stackView)
        }
    }
    
    @objc private func optionTapped(_ sender: UIButton) { //refactor?
        SearchManager.shared.isInResultVC = true
        guard let option = sender.titleLabel?.text else {
            return
        }
        var isFound = false
        SearchManager.shared.currentlySelected.forEach({ options in
            if options.value.contains(option) {
                isFound = true
                return
            }
        })
        
        if !isFound {
            if option.starts(with: "Under") {
                SearchManager.shared.currentlySelected["Difficulty"] = [option]
            } else {
                if let _ = SearchManager.shared.currentlySelected[SearchManager.shared.headersForSearch[sender.tag]] {
                    SearchManager.shared.currentlySelected[SearchManager.shared.headersForSearch[sender.tag]]?.insert(option)
                } else {
                    SearchManager.shared.currentlySelected[SearchManager.shared.headersForSearch[sender.tag]] = [option]
                }
            }
        }
        
        delegate?.optionButtonClicked(with: option, shouldAddButton: !isFound)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        print(stackView.arrangedSubviews.count)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
