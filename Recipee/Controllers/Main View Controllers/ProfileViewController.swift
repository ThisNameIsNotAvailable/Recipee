//
//  ProfileViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit
import FirebaseAuth
import AVFoundation

class ProfileViewController: FoldersViewController {
    
    private let tableViewHeader = ProfileHeader()
    
    private var loginView = LoginView()
    
    private let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .element
        title = "Profile"
        tableViewHeader.delegate = self
        tableViewHeader.configure()
        loginView.delegate = self
        layout()
        NotificationCustom.shared.addObserver(observer: self, name: .updateFolders) { [weak self] in
            self?.updateTableView()
        }
    }
    
    @objc private func updateTableView() {
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            loginView.isHidden = false
            tableView.isHidden = true
            tableViewHeader.isHidden = true
        } else {
            loginView.isHidden = true
            tableView.isHidden = false
            tableViewHeader.isHidden = false
        }
    }
    
    private func layout() {
        view.addSubview(tableView)
        view.addSubview(loginView)
        view.addSubview(tableViewHeader)
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height / 3
        
        NSLayoutConstraint.activate([
            tableViewHeader.heightAnchor.constraint(equalToConstant: height),
            tableViewHeader.widthAnchor.constraint(equalToConstant: width),
            tableViewHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableViewHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewHeader.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ProfileViewController: LoginViewDelegate {
    func didSignIn() {
        tableViewHeader.configure()
        loginView.isHidden = true
        tableView.isHidden = false
        tableViewHeader.isHidden = false
        updateTableView()
        NotificationCenter.default.post(name: .updateCollectionView, object: nil)
        NotificationCenter.default.post(name: .updateHeartButton, object: nil)
    }
}

extension ProfileViewController: ProfileTableHeaderDelegate {
    func didSignOut() {
        loginView.isHidden = false
        tableView.isHidden = true
        tableViewHeader.isHidden = true
        NotificationCenter.default.post(name: .updateHeartButton, object: nil)
        NotificationCenter.default.post(name: .updateCollectionView, object: nil)
    }
}

extension ProfileViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UINavigationController(rootViewController: FolderViewController(folderName: folders[indexPath.row].title))
        vc.title = folders[indexPath.row].title
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
                return
            }
            DatabaseManager.shared.removeFolder(with: folders[indexPath.row].title, for: email) { [weak self] success in
                if success {
                    self?.folders.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
