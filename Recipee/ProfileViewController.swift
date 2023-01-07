//
//  ProfileViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.showsVerticalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .background
        table.contentInsetAdjustmentBehavior = .never
        table.register(NewFolderHeader.self, forHeaderFooterViewReuseIdentifier: NewFolderHeader.identifier)
        return table
    }()
    
    private let tableViewHeader = ProfileHeader()
    
    private var loginView = LoginView()
    
    private var folders = ["dfd"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .element
        title = "Profile"
        configureTableView()
        loginView.delegate = self
        layout()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableViewHeader.delegate = self
        tableViewHeader.configure()
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NewFolderHeader()
        return header
    }
}

extension ProfileViewController: LoginViewDelegate {
    func didSignIn() {
        tableViewHeader.configure()
        loginView.isHidden = true
        tableView.isHidden = false
        tableViewHeader.isHidden = false
    }
}

extension ProfileViewController: ProfileTableHeaderDelegate {
    func didSignOut() {
        loginView.isHidden = false
        tableView.isHidden = true
        tableViewHeader.isHidden = true
        NotificationCenter.default.post(name: .updateHeartButton, object: nil)
    }
}
