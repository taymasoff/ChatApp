//
//  NewMessageView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.11.2021.
//

import UIKit

final class NewMessageView: UIView {
    
    // MARK: - Properties    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        let tintedImage = R.image.add()?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = ThemeManager.currentTheme.settings.tintColor
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        let tintedImage = R.image.send()?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = ThemeManager.currentTheme.settings.tintColor
        button.isEnabled = false
        return button
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type your message..."
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.textAlignment = .left
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .send
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        return textField
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 15
        return stackView
    }()
    
    // MARK: - Initializers
    init() {
        super.init(frame: CGRect.zero)
        setupView()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        self.backgroundColor = ThemeManager.currentTheme.settings.backGroundColor
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMaxXMinYCorner,
                                          .layerMinXMinYCorner]
    }
    
    func setupSubviews() {
        addSubview(stackView)
        
        textField.setContentHuggingPriority(UILayoutPriority(200), for: .horizontal)
        textField.setContentCompressionResistancePriority(UILayoutPriority(200), for: .horizontal)
        
        [addButton, textField, sendButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(textField.intrinsicContentSize.height + 8)
        }
        
        addButton.snp.makeConstraints { make in
            make.size.equalTo(textField.snp.height).inset(8)
        }
        
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(textField.snp.height).inset(8)
        }
    }
}
