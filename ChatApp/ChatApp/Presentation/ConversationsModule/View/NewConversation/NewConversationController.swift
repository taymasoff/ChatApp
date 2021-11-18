//
//  NewConversationViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.11.2021.
//

import UIKit
import SnapKit
import Rswift

class NewConversationController: NSObject {
    
    enum ViewState { case collapsed, revealed }
    enum AnimationsState { case on(duration: TimeInterval), off }
    
    // MARK: - Properties
    private weak var superView: UIView? {
        didSet {
            resetSubviews()
        }
    }
    private let newConversationView: NewConversationView
    
    let revealButton: UIButton = {
        let button = UIButton(type: .system)
        let tintedImage = R.image.add()?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.backgroundColor = ThemeManager.currentTheme.settings.secondaryColor
        button.tintColor = ThemeManager.currentTheme.settings.tintColor
        return button
    }()
    
    private var isSendable: Bool {
        if viewState == .revealed {
            return isTextSendable(text: newConversationView.nameTextField.text)
        } else {
            return false
        }
    }
    
    private var animationsState: AnimationsState
    
    private var viewState: ViewState = .collapsed {
        didSet {
            switch viewState {
            case .collapsed:
                newConversationView.isHidden = true
                newConversationView.nameTextField.resignFirstResponder()
            case .revealed:
                newConversationView.isHidden = false
                newConversationView.nameTextField.becomeFirstResponder()
            }
        }
    }
    
    var onAddConversationPressed: ((_ text: String) -> Void)?
    
    // MARK: - Init
    init(newConversationView: NewConversationView,
         animationsState: NewConversationController.AnimationsState = .on(duration: 0.2)) {
        self.newConversationView = newConversationView
        self.animationsState = animationsState
    }
    
    // MARK: - Action Methods
    @objc
    private func revealNewConversationButtonPressed() {
        revealNewConversationView()
    }
    
    @objc
    private func addNewConversationButtonPressed() {
        onAddConversationPressed?(newConversationView.nameTextField.text ?? "")
        newConversationView.nameTextField.text = ""
        collapseNewConversationView()
    }
    
    @objc
    private func cancelAddingConversationButtonPressed() {
        collapseNewConversationView()
    }
    
    // MARK: - Methods
    
    /// Добавить newConversationView и addNewConversationButton к иерархии переданного вью с заданными констрейнтами и выполнить настройку
    /// - Parameters:
    ///   - view: вью, на который следует расположить newConversationView
    ///   - constraints: SnapKit constraints maker
    func addToView(_ view: UIView, constraints: (_ make: ConstraintMaker) -> Void) {
        superView = view
        superView?.addSubview(revealButton)
        superView?.addSubview(newConversationView)
        revealButton.snp.makeConstraints(constraints)
        
        setupAddConversationButton()
        setupNewConversationView()
    }
    
    private func isTextSendable(text: String?) -> Bool {
        if let text = text,
           text.isntEmptyOrWhitespaced {
            return true
        } else {
            return false
        }
    }
    
    private func updateNewConversationViewOkButton() {
        newConversationView.okButton.isEnabled = isSendable
    }
}

// MARK: - Update NewConversationViewState
private extension NewConversationController {
    
    func revealNewConversationView() {
        
        newConversationView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(revealButton)
            make.height.equalToSuperview().dividedBy(6)
        }
        
        if case .on(let duration) = animationsState {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseOut]) { [weak self] in
                self?.superView?.layoutIfNeeded()
            }
        }
        
        viewState = .revealed
        newConversationView.okButton.isEnabled = isSendable
    }
    
    func collapseNewConversationView(animated: Bool = true) {
        newConversationView.snp.remakeConstraints { make in
            make.edges.equalTo(revealButton)
        }
        
        if case .on(let duration) = animationsState {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations: { [weak self] in
                self?.superView?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.viewState = .collapsed
            })
        } else {
            viewState = .collapsed
        }
    }
}

// MARK: - UITextFieldDelegate
extension NewConversationController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isSendable {
            addNewConversationButtonPressed()
            return true
        } else {
            return false
        }
    }
    
    @objc
    func nameTextFieldDidChange(_ textField: UITextField) {
        updateNewConversationViewOkButton()
    }
}

// MARK: - Setup Subviews Methods
private extension NewConversationController {
    
    func setupAddConversationButton() {
        guard let superView = superView else { return }
        let buttonSize = superView.frame.width / 6
        revealButton.imageEdgeInsets = UIEdgeInsets(top: CGFloat(buttonSize / 3),
                                              left: CGFloat(buttonSize / 3),
                                              bottom: CGFloat(buttonSize / 3),
                                              right: CGFloat(buttonSize / 3))
        revealButton.layer.cornerRadius = CGFloat(buttonSize / 2)
    
        revealButton.addTarget(
            self,
            action: #selector(revealNewConversationButtonPressed),
            for: .touchUpInside
        )
    }
    
    func setupNewConversationView() {
        newConversationView.nameTextField.delegate = self
    
        newConversationView.okButton.addTarget(
            self,
            action: #selector(addNewConversationButtonPressed),
            for: .touchUpInside
        )
        newConversationView.cancelButton.addTarget(
            self,
            action: #selector(cancelAddingConversationButtonPressed),
            for: .touchUpInside
        )
        
        newConversationView.snp.makeConstraints { make in
            make.edges.equalTo(revealButton)
        }
        
        newConversationView.nameTextField.addTarget(
            self,
            action: #selector(nameTextFieldDidChange),
            for: .editingChanged
        )
        
        viewState = .collapsed
    }
    
    func resetSubviews() {
        viewState = .collapsed
        revealButton.snp.removeConstraints()
        revealButton.removeTarget(self, action: nil, for: .touchUpInside)
        newConversationView.snp.removeConstraints()
        newConversationView.nameTextField.removeTarget(self, action: nil, for: .allEvents)
        newConversationView.okButton.removeTarget(self, action: nil, for: .allEvents)
        newConversationView.cancelButton.removeTarget(self, action: nil, for: .allEvents)
    }
}
