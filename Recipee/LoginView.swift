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
import FBSDKLoginKit

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
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        return button
    }()
    
    private let facebookSignIn: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Sign In With Facebook", attributes: [.font: UIFont.appFont(of: 20)]), for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .selection
        button.tintColor = .black
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.configuration = UIButton.Configuration.borderless()
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        return button
    }()
    
    weak var delegate: LoginViewDelegate?
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .background
        layout()
        googleSignIn.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        facebookSignIn.addTarget(self, action: #selector(facebookSignInTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(googleSignIn)
        stackView.addArrangedSubview(facebookSignIn)
        
        stackView.sizeToFit()
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func lockButtons() {
        googleSignIn.isUserInteractionEnabled = false
        facebookSignIn.isUserInteractionEnabled = false
    }
    
    private func unlockButtons() {
        googleSignIn.isUserInteractionEnabled = true
        facebookSignIn.isUserInteractionEnabled = true
    }
    
    @objc private func googleSignInTapped() {
        lockButtons()
        guard let rootVC = delegate as? UIViewController else {
            unlockButtons()
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
                self?.unlockButtons()
                return
            }

            guard
                let accessToken = result?.user.accessToken.tokenString,
                let idToken = result?.user.idToken?.tokenString
            else {
                self?.unlockButtons()
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                guard authResult != nil, error == nil else {
                    print(error?.localizedDescription ?? "error occured")
                    self?.unlockButtons()
                    return
                }
                NotificationCenter.default.post(name: .updateHeartButton, object: nil)
                self?.delegate?.didSignIn()
                self?.unlockButtons()
            }
        }
    }
    
    @objc private func facebookSignInTapped() {
        lockButtons()
        guard let rootVC = delegate as? UIViewController else {
            unlockButtons()
            return
        }
        
        FBSDKLoginKit.LoginManager().logIn(permissions: ["public_profile", "email"], from: rootVC) { [weak self] result, error in
            if let error = error {
                print(error.localizedDescription)
                self?.unlockButtons()
                return
            }
            
            guard let token = AccessToken.current?.tokenString else {
                self?.unlockButtons()
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                guard authResult != nil, error == nil else {
                    self?.unlockButtons()
                    print(error?.localizedDescription ?? "error occured")
                    return
                }
                NotificationCenter.default.post(name: .updateHeartButton, object: nil)
                self?.delegate?.didSignIn()
                self?.unlockButtons()
            }
        }
    }
}
