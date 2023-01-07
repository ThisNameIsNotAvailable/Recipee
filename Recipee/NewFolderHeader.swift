//
//  NewFolderHeader.swift
//  Recipee
//
//  Created by Alex on 07/01/2023.
//

import UIKit

class NewFolderHeader: UITableViewHeaderFooterView {
    
    static let identifier = "NewFolderHeader"
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        let title = NSMutableAttributedString(string: "+", attributes: [
            .font: UIFont.appFont(of: 20, isBold: true),
            .foregroundColor: UIColor.black])
        title.append(NSAttributedString(string: " Create new folder", attributes: [
            .font: UIFont.appFont(of: 16, isBold: true),
            .foregroundColor: UIColor.black]))
        button.setAttributedTitle(title, for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layout()
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func createTapped() {
        print("gf")
    }
    
    private func layout() {
        button.sizeToFit()
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
