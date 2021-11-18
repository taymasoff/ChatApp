//
//  InAppNotificationView.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 20.10.2021.
//

import UIKit
import SnapKit

/*
 👉 Вьюха, отображающая нотификационный баннер внутри приложения сверху презентующего вью.
    Доступны опции презентации Успеха и Ошибки
    На входе доступны опциональные параметры: Заголовока, тела и до 2 кнопок
 */

final class InAppNotificationBanner: ViewModelBased, ViewModelBindable, Configurable {
    
    private let view: InAppNotificationView
    
    private var onScreen: Bool = false
    
    var onButtonOnePress: (() -> Void)?
    var onButtonTwoPress: (() -> Void)?
    
    var viewModel: InAppNotificationViewModel?
    
    init(with view: InAppNotificationView? = nil) {
        if let view = view {
            self.view = view
        } else {
            self.view = InAppNotificationView()
        }
        setupGestures()
    }
    
    // Презентуем на заданной вьюшке или KeyWindow, в последнем случае уведомление не пропадет, если дизмиснуть вьюху
    func show(at view: UIView? = UIApplication.shared
                .windows.first(where: { $0.isKeyWindow }),
              for seconds: Int? = 5) {
        
        guard let parentView = view else { return }
        
        onScreen = true

        parentView.addSubview(self.view)
        
        self.view.layer.cornerRadius = 18
        self.view.layer.maskedCorners = [.layerMinXMaxYCorner,
                                    .layerMaxXMaxYCorner]
        
        self.view.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(seconds ?? 5)) {
            [weak self] in
            self?.dismiss()
        }
    }
    
    @objc
    func dismiss() {
        if onScreen {
            self.view.snp.removeConstraints()
            self.view.clearSubviews()
            onScreen = false
            self.view.removeFromSuperview()
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
    
    func bindWithViewModel() {
        viewModel?.headerText.bind(listener: { [unowned self] text in
            self.view.headerLabel.text = text
        })
        
        viewModel?.bodyText.bind(listener: { [unowned self] text in
            self.view.bodyLabel.text = text
        })
        
        viewModel?.notificationType.bind(listener: { [unowned self] type in
            switch type {
            case .success:
                self.view.backgroundColor = .systemGreen.withAlphaComponent(0.9)
            case .error:
                self.view.backgroundColor = .systemPink.withAlphaComponent(0.9)
            }
        })
        
        viewModel?.buttonOneText.bind(listener: { [unowned self] text in
            guard let text = text, text != "" else { return }
            self.updateButtonOne(with: text)
        })
        
        viewModel?.buttonTwoText.bind(listener: { [unowned self] text in
            guard let text = text, text != "" else { return }
            self.updateButtonTwo(with: text)
        })
    }
    
    private func updateButtonOne(with text: String) {
        view.setButtonOne(to: text)
        view.buttonOne?.addTarget(self,
                                 action: #selector(onButtonOnePressed),
                                 for: .touchUpInside)
    }
    
    private func updateButtonTwo(with text: String) {
        view.setButtonTwo(to: text)
        view.buttonTwo?.addTarget(self,
                                 action: #selector(onButtonTwoPressed),
                                 for: .touchUpInside)
    }
    
    private func setupGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self,
                                               action: #selector(dismiss))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
    }
}
