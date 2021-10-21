//
//  InAppNotificationView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 20.10.2021.
//

import UIKit
import SnapKit
import Rswift

/*
 👉 Вьюха, отображающая нотификационный баннер внутри приложения сверху презентующего вью.
    Доступны опции презентации Успеха и Ошибки
    На входе доступны опциональные параметры: Заголовока, тела и до 2 кнопок
 */

final class InAppNotificationView: UIView, ViewModelBased, ViewModelBindable, Configurable {
    
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
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private var buttonOne: UIButton?
    private var buttonTwo: UIButton?

    private var onScreen: Bool = false
    
    var onButtonOnePress: (() -> Void)?
    var onButtonTwoPress: (() -> Void)?
    
    var viewModel: InAppNotificationViewModel?
    
    // MARK: - Init
    init() {
        super.init(frame: CGRect.zero)
        setupSubviews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Презентуем на заданной вьюшке или KeyWindow, в последнем случае уведомление не пропадет, если дизмиснуть вьюху
    func show(at view: UIView? = UIApplication.shared
                .windows.first(where: { $0.isKeyWindow }),
              for seconds: Int? = 5) {
        
        guard let view = view else { return }
        
        onScreen = true

        view.addSubview(self)
        
        self.layer.cornerRadius = 18
        self.layer.maskedCorners = [.layerMinXMaxYCorner,
                                    .layerMaxXMaxYCorner]
        
        self.snp.remakeConstraints({ make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
        })
        
        layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(seconds ?? 5)) {
            [weak self] in
            self?.dismiss()
        }
    }
    
    @objc
    func dismiss() {
        if onScreen {
            self.snp.removeConstraints()
            self.clearSubviews()
            onScreen = false
            self.removeFromSuperview()
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
        
        mainStackView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().inset(10)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(5)
        }
        layoutIfNeeded()
    }
    
    func bindWithViewModel() {
        viewModel?.headerText.bind(listener: { [unowned self] text in
            self.headerLabel.text = text
        })
        
        viewModel?.bodyText.bind(listener: { [unowned self] text in
            self.bodyLabel.text = text
        })
        
        viewModel?.notificationType.bind(listener: { [unowned self] type in
            switch type {
            case .success:
                self.backgroundColor = R.color.successColor()
            case .error:
                self.backgroundColor = R.color.errorColor()
            }
        })
        
        viewModel?.buttonOneText.bind(listener: { [unowned self] text in
            guard let text = text, text != "" else { return }
            clearButtonOne()
            self.buttonOne = makeCalloutButton()
            // makeCalloutButton всегда возвращает nonOptional Button, поэтому '!'
            self.buttonOne!.setTitle(text, for: .normal)
            self.buttonOne!.addTarget(self,
                             action: #selector(onButtonOnePressed),
                             for: .touchUpInside)
            self.buttonsStackView.addArrangedSubview(buttonOne!)
        })
        
        viewModel?.buttonTwoText.bind(listener: { [unowned self] text in
            guard let text = text, text != "" else { return }
            clearButtonTwo()
            self.buttonTwo = makeCalloutButton()
            // makeCalloutButton всегда возвращает nonOptional Button, поэтому '!'
            self.buttonTwo!.setTitle(text, for: .normal)
            self.buttonTwo!.addTarget(self,
                             action: #selector(onButtonTwoPressed),
                             for: .touchUpInside)
            self.buttonsStackView.addArrangedSubview(buttonTwo!)
        })
    }
    
    private func clearSubviews() {
        self.headerLabel.text = nil
        self.bodyLabel.text = nil
        
        clearButtonOne()
        clearButtonTwo()
    }
    
    private func clearButtonOne() {
        if let buttonOne = buttonOne {
            buttonOne.removeTarget(self,
                                   action: #selector(onButtonOnePressed),
                                   for: .touchUpInside)
            buttonsStackView.removeArrangedSubview(buttonOne)
            self.buttonOne = nil
        }
    }
    
    private func clearButtonTwo() {
        if let buttonTwo = buttonTwo {
            buttonTwo.removeTarget(self,
                                   action: #selector(onButtonTwoPressed),
                                   for: .touchUpInside)
            buttonsStackView.removeArrangedSubview(buttonTwo)
            self.buttonTwo = nil
        }
    }
    
    private func setupGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self,
                                               action: #selector(dismiss))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
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
