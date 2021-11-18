//
//  KeyboardObserving.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 18.11.2021.
//

import UIKit

protocol KeyboardObserving: AnyObject {
    func addKeyboardObserver()
    func keyboardWillShow(keyboardSize: CGRect, duration: Double)
    func keyboardWillHide(duration: Double)
}

extension UIViewController {
    @objc
    func adjustForKeyboard(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
                .cgRectValue,
              let duration = notification
                .userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
                    return
                }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            if let keyboardObserver = self as? KeyboardObserving {
                keyboardObserver.keyboardWillShow(keyboardSize: keyboardSize,
                                                  duration: duration)
            }
        }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            if let keyboardObserver = self as? KeyboardObserving {
                keyboardObserver.keyboardWillHide(duration: duration)
            }
        }
    }
}

extension KeyboardObserving where Self: UIViewController {
    func addKeyboardObserver() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(adjustForKeyboard),
                         name: UIResponder.keyboardWillShowNotification,
                         object: nil)
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(adjustForKeyboard),
                         name: UIResponder.keyboardWillHideNotification,
                         object: nil)
    }
}
