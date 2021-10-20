//
//  InAppNotificationView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 20.10.2021.
//

import UIKit
import SnapKit
import Rswift

class InAppNotificationView: UIView {
    
    enum NotificationType: String {
        case success = "Успех"
        case error = "Ошибка"
    }
    
    // MARK: - Properties
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    var buttonOne: UIButton?
    var buttonTwo: UIButton?
    var onButtonOnePress: (() -> Void)?
    var onButtonTwoPress: (() -> Void)?
    
    init(notificationType: NotificationType,
         headerText: String? = nil,
         bodyText: String? = nil,
         buttonOneText: String? = nil,
         buttonTwoText: String? = nil) {
        self.headerLabel.text = headerText ?? notificationType.rawValue
        self.bodyLabel.text = bodyText
                        
        super.init(frame: CGRect.zero)
        
        switch notificationType {
        case .success:
            self.backgroundColor = R.color.successColor()
        case .error:
            self.backgroundColor = R.color.errorColor()
        }
        
        if buttonOneText != nil {
            self.buttonOne = makeCalloutButton()
            self.buttonOne?.setTitle(buttonOneText, for: .normal)
        }
        
        if buttonTwoText != nil {
            self.buttonTwo = makeCalloutButton()
            self.buttonTwo?.setTitle(buttonTwoText, for: .normal)
        }
        
        setupSubviews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(dismiss))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
    }
    
    func show(at view: UIView? = UIApplication.shared.windows.last,
              for seconds: Int? = 3) {
        
        guard let view = view else { return }
        
        view.addSubview(self)
        
        self.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.snp.top)
        }
        
        layoutIfNeeded()
        
        self.layer.cornerRadius = 18
        self.layer.maskedCorners = [.layerMinXMaxYCorner,
                                    .layerMaxXMaxYCorner]
        
        self.snp.remakeConstraints({ make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
        })
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.layoutIfNeeded()
        } completion: { _ in
            DispatchQueue.main.asyncAfter(
                deadline: .now() + TimeInterval(seconds ?? 3)
            ) { [weak self] in
                self?.dismiss()
            }
        }
    }
    
    @objc
    func dismiss() {
        self.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.5, delay: 1, animations: { [weak self] in
            self?.layoutIfNeeded()
        }) { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    @objc
    private func onButtonOnePressed() {
        onButtonOnePress?()
    }
    
    @objc
    private func onButtonTwoPressed() {
        onButtonTwoPress?()
    }
    
    private func setupSubviews() {
        guard let window = UIApplication.shared.windows.last else { return }
        var frame = window.frame
        frame.size.height = frame.height * 0.15
        frame.origin.y = frame.origin.y - frame.size.height
        self.frame = frame
        
        addSubview(mainStackView)
        mainStackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(headerLabel)
        textStackView.addArrangedSubview(bodyLabel)
        mainStackView.addArrangedSubview(buttonsStackView)
        
        if let buttonOne = buttonOne {
            buttonsStackView.addArrangedSubview(buttonOne)
            buttonOne.addTarget(self,
                                action: #selector(onButtonOnePressed),
                                for: .touchUpInside)
        }
        if let buttonTwo = buttonTwo {
            buttonsStackView.addArrangedSubview(buttonTwo)
            buttonTwo.addTarget(self,
                                action: #selector(onButtonTwoPressed),
                                for: .touchUpInside)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().inset(10)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(5)
        }
        layoutIfNeeded()
    }
    
    private func makeCalloutButton() -> UIButton {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.backgroundColor = R.color.appYellow()
        button.setTitleColor(.black,
                             for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }
}
