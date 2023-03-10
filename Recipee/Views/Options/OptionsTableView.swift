//
//  OptionsTableView.swift
//  Recipee
//
//  Created by Alex on 28/12/2022.
//

import UIKit

class OptionsTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        translatesAutoresizingMaskIntoConstraints = false
        separatorColor = .clear
        register(OptionsTableViewCell.self, forCellReuseIdentifier: OptionsTableViewCell.identifier)
        delaysContentTouches = false
        backgroundColor = .background
        showsVerticalScrollIndicator = false
        register(SearchTableViewHeader.self, forHeaderFooterViewReuseIdentifier: SearchTableViewHeader.identifier)
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 600
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
