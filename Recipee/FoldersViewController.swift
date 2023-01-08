//
//  FoldersViewController.swift
//  Recipee
//
//  Created by Alex on 08/01/2023.
//

import UIKit
import FirebaseAuth

class FoldersViewController: UIViewController {
    
    let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.showsVerticalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .background
        table.contentInsetAdjustmentBehavior = .never
        table.register(NewFolderHeader.self, forHeaderFooterViewReuseIdentifier: NewFolderHeader.identifier)
        table.register(FolderTableViewCell.self, forCellReuseIdentifier: FolderTableViewCell.identifier)
        return table
    }()
    
    var folders = [FoldersViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchData()
    }
    
    func fetchData() {
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        DatabaseManager.shared.getFolders(for: email) { [weak self] res in
            switch res {
            case .success(let model):
                self?.folders = model
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension FoldersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FolderTableViewCell.identifier, for: indexPath) as? FolderTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(with: folders[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NewFolderHeader()
        header.delegate = self
        return header
    }
}

extension FoldersViewController: NewFolderHeaderDelegate {
    func createNewTapped() {
        let ac = UIAlertController(title: "Add New Folder", message: "Please enter new folders's title.", preferredStyle: .alert)
        var field = UITextField()
        ac.addTextField { textField in
            textField.placeholder = "Folder's name..."
            field = textField
        }
        ac.addAction(UIAlertAction(title: "Add New", style: .default, handler: { [weak self] _ in
            guard let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty, let strongSelf = self, let condition = self?.folders.contains(where: { model in
                model.title == text
            }), let email = FirebaseAuth.Auth.auth().currentUser?.email else {
                print("The title is blank or folder with the same title already exists.")
                return
            }
            if !condition {
                DatabaseManager.shared.addNewFolder(with: text, for: email) { success in
                    if success {
                        strongSelf.folders.insert(FoldersViewModel(image: "", title: text), at: 0)
                        DispatchQueue.main.async {
                            strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                            NotificationCenter.default.post(name: .updateFolders, object: nil)
                        }
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
