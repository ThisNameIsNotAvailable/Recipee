//
//  OptionsViewController.swift
//  Recipee
//
//  Created by Alex on 28/12/2022.
//

import UIKit

class OptionsViewController: UIViewController, OptionCollectionViewCellDelegate {
    
    func optionButtonClicked(with option: String, shouldAddButton: Bool) {
        if shouldAddButton {
            completion?(option)
        }
        dismiss(animated: true)
    }
    
    private let searchTableView: UITableView = {
        let tv = OptionsTableView(frame: .zero, style: .grouped)
        return tv
    }()
    
    var completion: ((_: String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Option"
        view.backgroundColor = .background
        layout()
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    private func layout() {
        view.addSubview(searchTableView)
        
        NSLayoutConstraint.activate([
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchTableView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource {
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
        header.configure(title: SearchManager.shared.headersForSearch[section + 1])
        return header
    }
}
