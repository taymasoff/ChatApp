//
//  UIImageView+addAction.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 25.10.2021.
//

import UIKit
import SnapKit

internal extension UIImageView {
    /// Добавляет action на родительский ImageView
    /// - Parameters:
    ///   - target: target
    ///   - action: selector
    func addAction(target: Any?, action: Selector) {
        let button = UIButton(type: .system)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
