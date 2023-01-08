//
//  ProfileTableHeader.swift
//  Recipee
//
//  Created by Alex on 06/01/2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import SDWebImage

protocol ProfileTableHeaderDelegate: AnyObject {
    func didSignOut()
}

class ProfileHeader: UIView {
    
    weak var delegate: ProfileTableHeaderDelegate?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 3/10 * UIScreen.main.bounds.height / 3
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .appFont(of: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Out", for: .normal)
        button.titleLabel?.font = .appFont(of: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .selection
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layout()
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func signOut() {
        GIDSignIn.sharedInstance.signOut()
        FBSDKLoginKit.LoginManager().logOut()
        do {
            try FirebaseAuth.Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        delegate?.didSignOut()
    }
    
    private func layout() {
        addSubview(profileImageView)
        addSubview(signOutButton)
        addSubview(nameLabel)
        let divider = UIView()
        divider.backgroundColor = .gray
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)
        
        let width = 3/5 * UIScreen.main.bounds.height / 3
        
        NSLayoutConstraint.activate([
            
            divider.widthAnchor.constraint(equalTo: widthAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            profileImageView.heightAnchor.constraint(equalToConstant: width),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            profileImageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: profileImageView.bottomAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 1),
            
            bottomAnchor.constraint(equalToSystemSpacingBelow: signOutButton.bottomAnchor, multiplier: 1),
            signOutButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: signOutButton.trailingAnchor, multiplier: 1)
        ])
    }
    
    func configure() {
        nameLabel.text = FirebaseAuth.Auth.auth().currentUser?.displayName
        guard let providerName = FirebaseAuth.Auth.auth().currentUser?.providerData.first?.providerID else {
            return
        }
        if providerName == "facebook.com" {
            if let imageURL = Profile.current?.imageURL {
                profileImageView.sd_setImage(with: imageURL)
            }
        } else {
            if let defaultURL = FirebaseAuth.Auth.auth().currentUser?.photoURL {
                profileImageView.sd_setImage(with: defaultURL)
            }
        }
    }
}
