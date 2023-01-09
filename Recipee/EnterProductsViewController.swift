//
//  EnterProductsViewController.swift
//  Recipee
//
//  Created by Alex on 09/01/2023.
//

import UIKit

class EnterProductsViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .top
        stack.spacing = 10
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "Enter up to 5 ingredients."
        label.font = .appFont(of: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let findButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Find Recipes", attributes: [
            .font: UIFont.appFont(of: 18),
            .foregroundColor: UIColor.black]), for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = .element
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8)
        return button
    }()
    
    var onButtonTap: ((String) -> ())!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        
        navigationController?.navigationBar.tintColor = .black
        layout()
        findButton.addTarget(self, action: #selector(findTapped), for: .touchUpInside)
    }
    
    @objc private func findTapped() {
        var str = ""
        for subview in stackView.arrangedSubviews {
            guard let textView = subview as? TextFieldWithNumberView else {
                continue
            }
            str += "\(textView.getTextInField()),"
        }
        if !str.isEmpty {
            str.removeLast()
            onButtonTap(str)
        } else {
            print("Enter some ingredients.")
        }
        
    }
    
    @objc private func backTapped() {
        dismiss(animated: true)
    }
    
    private func layout() {
        stackView.addArrangedSubview(hintLabel)
        let textField = TextFieldWithNumberView(number: 1)
        textField.becomeFirstResponder()
        textField.delegate = self
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(findButton)
        
        stackView.sizeToFit()
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            textField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            findButton.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }
}

extension EnterProductsViewController: TextFieldWithNumberViewDelegate {
    func clearButtonTapped(_ textView: TextFieldWithNumberView) {
        if stackView.arrangedSubviews.count != 3 {
            textView.removeFromSuperview()
            stackView.layoutIfNeeded()
            guard let last = stackView.arrangedSubviews[stackView.arrangedSubviews.count - 2] as? TextFieldWithNumberView else {
                return
            }
            last.becomeFirstResponder()
            correctNumbers()
        }
    }
    
    func returnButtonTapped(_ textView: TextFieldWithNumberView) {
        if stackView.arrangedSubviews.count != 7 {
            let textField = TextFieldWithNumberView(number: stackView.arrangedSubviews.count)
            textField.delegate = self
            stackView.insertArrangedSubview(textField, at: stackView.arrangedSubviews.count - 1)
            NSLayoutConstraint.activate([
                textField.widthAnchor.constraint(equalTo: stackView.widthAnchor)
            ])
            stackView.layoutIfNeeded()
            textField.becomeFirstResponder()
            correctNumbers()
        }
    }
    
    func canEdit(_ textView: TextFieldWithNumberView) -> Bool {
        guard let last = stackView.arrangedSubviews[stackView.arrangedSubviews.count - 2] as? TextFieldWithNumberView else {
            return false
        }
        return last == textView
    }
    
    private func correctNumbers() {
        for (i, subview) in stackView.arrangedSubviews.enumerated() {
            guard let textView = subview as? TextFieldWithNumberView else {
                continue
            }
            textView.setNumber(to: i)
        }
    }
}
