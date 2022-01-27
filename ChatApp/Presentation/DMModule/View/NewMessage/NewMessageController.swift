//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.11.2021.
//

import UIKit
import SnapKit

class NewMessageController: NSObject {
    
    // MARK: - Properties
    private weak var superView: UIView? {
        didSet {
            resetSubviews()
        }
    }
    
    let newMessageView: NewMessageView
    
    private var isSendable: Bool {
        return isTextSendable(text: newMessageView.textField.text)
    }
    
    var onSendMessagePressed: ((_ text: String) -> Void)?
    var onAddButtonPressed: ((_ sender: UIButton) -> Void)?
    
    // MARK: - Init
    init(newMessageView: NewMessageView) {
        self.newMessageView = newMessageView
    }
    
    // MARK: - Action Methods
    @objc
    private func addButtonPressed() {
        onAddButtonPressed?(newMessageView.addButton)
    }
    
    @objc
    private func sendButtonPressed() {
        onSendMessagePressed?(newMessageView.textField.text ?? "")
        newMessageView.textField.text = ""
    }
    
    // MARK: - Methods
    
    /// Добавить newMessageView к иерархии переданного вью с заданными констрейнтами и выполнить настройку
    /// - Parameters:
    ///   - view: вью, на который следует расположить newMessageView
    ///   - constraints: SnapKit constraints maker
    func addToView(_ view: UIView, constraints: (_ make: ConstraintMaker) -> Void) {
        superView = view
        superView?.addSubview(newMessageView)
        newMessageView.snp.makeConstraints(constraints)
        
        setupNewMessageView()
    }
    
    private func isTextSendable(text: String?) -> Bool {
        if let text = text,
           text.isntEmptyOrWhitespaced {
            return true
        } else {
            return false
        }
    }
    
    private func updateNewMessageViewSendButton() {
        newMessageView.sendButton.isEnabled = isSendable
    }
}

// MARK: - UITextFieldDelegate
extension NewMessageController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isSendable {
            sendButtonPressed()
            return true
        } else {
            return false
        }
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        updateNewMessageViewSendButton()
    }
}

// MARK: - Setup Subviews Methods
private extension NewMessageController {
    
    func setupNewMessageView() {
        newMessageView.textField.delegate = self
        
        newMessageView.sendButton.addTarget(self,
                                            action: #selector(sendButtonPressed),
                                            for: .touchUpInside)
        newMessageView.addButton.addTarget(self,
                                           action: #selector(addButtonPressed),
                                           for: .touchUpInside)
        newMessageView.textField.addTarget(self,
                                           action: #selector(textFieldDidChange),
                                           for: .editingChanged)
    }
    
    func resetSubviews() {
        newMessageView.snp.removeConstraints()
        newMessageView.sendButton.removeTarget(self, action: nil, for: .allEvents)
        newMessageView.addButton.removeTarget(self, action: nil, for: .allEvents)
        newMessageView.textField.removeTarget(self, action: nil, for: .allEvents)
    }
}
