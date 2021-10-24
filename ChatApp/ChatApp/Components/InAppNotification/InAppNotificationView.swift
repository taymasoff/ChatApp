//
//  InAppNotificationView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 25.10.2021.
//

import UIKit
import SnapKit
import Rswift

final class InAppNotificationView: UIView {
    // MARK: - Properties
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
    }()
    
    let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    var buttonOne: UIButton?
    var buttonTwo: UIButton?
    
    // MARK: - Init
    init() {
        super.init(frame: CGRect.zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        guard let window = UIApplication.shared.windows.last else { return }
        var frame = window.frame
        frame.size.height = frame.height * 0.15
        frame.origin.y -= frame.size.height
        self.frame = frame
        
        addSubview(mainStackView)
        mainStackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(headerLabel)
        textStackView.addArrangedSubview(bodyLabel)
        mainStackView.addArrangedSubview(buttonsStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().inset(10)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(5)
        }
        layoutIfNeeded()
    }
    
    func setButtonOne(to text: String) {
        clearButtonOne()
        buttonOne = makeCalloutButton()
        // makeCalloutButton всегда возвращает nonOptional Button, поэтому '!'
        buttonOne!.setTitle(text, for: .normal)
        buttonsStackView.addArrangedSubview(buttonOne!)
    }
    
    func setButtonTwo(to text: String) {
        clearButtonTwo()
        buttonTwo = makeCalloutButton()
        // makeCalloutButton всегда возвращает nonOptional Button, поэтому '!'
        buttonTwo!.setTitle(text, for: .normal)
        buttonsStackView.addArrangedSubview(buttonTwo!)
    }
    
    func clearSubviews() {
        headerLabel.text = nil
        bodyLabel.text = nil
        
        clearButtonOne()
        clearButtonTwo()
    }
    
    private func clearButtonOne() {
        if let buttonOne = buttonOne {
            buttonsStackView.removeArrangedSubview(buttonOne)
            self.buttonOne = nil
        }
    }
    
    private func clearButtonTwo() {
        if let buttonTwo = buttonTwo {
            buttonsStackView.removeArrangedSubview(buttonTwo)
            self.buttonTwo = nil
        }
    }
    
    private func makeCalloutButton() -> UIButton {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.backgroundColor = R.color.appYellow()
        button.setTitleColor(.black,
                             for: .normal)
        button.layer.cornerRadius = 8
        return button
    }
}
