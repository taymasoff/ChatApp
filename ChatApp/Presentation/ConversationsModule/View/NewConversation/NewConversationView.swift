//
//  NewConversationView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 26.10.2021.
//

import UIKit
import SnapKit

final class NewConversationView: UIView {
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New conversation name..."
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .default
        textField.clearButtonMode = .always
        textField.contentVerticalAlignment = .center
        return textField
    }()
    
    let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ok", for: .normal)
        button.setTitleColor(ThemeManager.currentTheme.settings.tintColor,
                             for: .normal)
        button.setTitleColor(ThemeManager.currentTheme.settings.tintColor
                                .withAlphaComponent(0.6),
                             for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.isEnabled = false
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(ThemeManager.currentTheme.settings.tintColor,
                             for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return button
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 15
        return stackView
    }()
    
    private let textFieldsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    var isSendable: Bool = false {
        didSet {
            okButton.isEnabled = isSendable
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = ThemeManager.currentTheme.settings.secondaryColor
        layer.cornerRadius = 18
        setupSubviewsHierarchy()
        setupSubviewsLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Subviews Setup
private extension NewConversationView {
    func setupSubviewsHierarchy() {
        addSubview(containerStackView)
        containerStackView.addArrangedSubview(textFieldsStackView)
        textFieldsStackView.addArrangedSubview(nameTextField)
        containerStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(okButton)
        buttonsStackView.addArrangedSubview(cancelButton)
    }
    
    func setupSubviewsLayout() {
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
    }
}
