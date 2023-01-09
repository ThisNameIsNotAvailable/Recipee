//
//  TextFieldWithNumberView.swift
//  Recipee
//
//  Created by Alex on 09/01/2023.
//

import UIKit

protocol TextFieldWithNumberViewDelegate: AnyObject {
    func clearButtonTapped(_ textView: TextFieldWithNumberView)
    func returnButtonTapped(_ textView: TextFieldWithNumberView)
    func canEdit(_ textView: TextFieldWithNumberView) -> Bool
}

class TextFieldWithNumberView: UIView {
    
    weak var delegate: TextFieldWithNumberViewDelegate?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(of: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField = TextField.createRoundedTextField()
    
    let number: Int
    
    init(number: Int) {
        self.number = number
        super.init(frame: .zero)
        numberLabel.text = "\(number)."
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        stackView.addArrangedSubview(numberLabel)
        textField.delegate = self
        stackView.addArrangedSubview(textField)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        numberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        textField.becomeFirstResponder()
        return true
    }
    
    func setNumber(to num: Int) {
        numberLabel.text = "\(num)."
    }
    
    func getTextInField() -> String {
        return textField.text ?? ""
    }
}

extension TextFieldWithNumberView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        delegate?.returnButtonTapped(self)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        delegate?.clearButtonTapped(self)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate!.canEdit(self)
    }
}
