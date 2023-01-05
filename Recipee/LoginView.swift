//
//  LoginView.swift
//  Recipee
//
//  Created by Alex on 05/01/2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol LoginViewDelegate: AnyObject {
    func didSignIn()
}

class LoginView: UIView {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .appFont(of: 40)
        label.textAlignment = .center
        label.text = "Log In Or Create Account To Add Your Favourite Recipes"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let googleSignIn: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Sign In With Google", attributes: [.font: UIFont.appFont(of: 20)]), for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .element
        button.tintColor = .black
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.configuration = UIButton.Configuration.borderless()
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        return button
    }()
    
    weak var delegate: LoginViewDelegate?
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layout()
        googleSignIn.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(googleSignIn)
        
        stackView.sizeToFit()
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    @objc private func googleSignInTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        
        guard let rootVC = delegate as? UIViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootVC) { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                guard authResult != nil, error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                NotificationCenter.default.post(name: .updateHeartButton, object: nil)
                self.delegate?.didSignIn()
            }
        }
    }
}
