//
//  ProfileViewController.swift
//  Recipee
//
//  Created by Alex on 25/12/2022.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    private let signOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Out", for: .normal)
        button.titleLabel?.font = .appFont(of: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private var loginView = LoginView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        loginView.delegate = self
        layout()
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            loginView.isHidden = false
            signOutButton.isHidden = true
        } else {
            loginView.isHidden = true
            signOutButton.isHidden = false
        }
    }
    
    @objc private func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        loginView.isHidden = false
        signOutButton.isHidden = true
        NotificationCenter.default.post(name: .updateHeartButton, object: nil)
    }
    
    private func layout() {
        view.addSubview(signOutButton)
        view.addSubview(loginView)
        
        NSLayoutConstraint.activate([
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ProfileViewController: LoginViewDelegate {
    func didSignIn() {
        loginView.isHidden = true
        signOutButton.isHidden = false
    }
}
