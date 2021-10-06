//
//  UIImageView+AddProfilePlaceholder.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.09.2021.
//

import UIKit
import SnapKit

/*
 👉 Добавляет в UIImageView желтый фон с инициалами, как в приложении тинькова.
 ⚙️ Использование: imageView.addProfilePlaceholder(fullName: "Oleg Tinkoff") -> OT
 */

extension UIImageView {
    
    /// Добавляет желтый фон с инициалами на родительский ImageView
    /// - Parameter fullName: Имя Фамилия
    func addProfilePlaceholder(fullName: String?) {
        let formatter = PersonNameComponentsFormatter()
        guard let fullName = fullName,
              let components = formatter.personNameComponents(from: fullName) else {
                  Log.error("Невозможно получить инициалы из строки: \(fullName ?? "")")
                  showPlaceholder("?")
                  return
              }
        
        formatter.style = .abbreviated
        let initials = formatter.string(from: components)
        addProfilePlaceholder(initials: initials)
    }
    
    /// Добавляет желтый фон с инициалами на родительский ImageView
    /// - Parameter initials: Инициалы (Например: "ОТ")
    func addProfilePlaceholder(initials: String) {
        guard initials.count == 2 else {
            Log.error("Введены неверные инициалы \(initials). \nВведите 2 буквы или воспользуйтесь функцией со входным значением fullName")
            showPlaceholder("?")
            return
        }
        showPlaceholder(initials)
    }
    
    private func showPlaceholder(_ initials: String) {
        self.image = AppAssets.image(.yellowCircle)
        let label = UILabel()
        // Тут магия по уменьшению шрифта так, чтобы он вписывался в лейбу
        label.font = AppAssets.font(.sfProDisplay, type: .semibold, size: 120)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        // Не знаю почему, но если поставить количество строк 1 и не выставить lineBreakMode шрифт не уменьшается меньше определенного значения
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = initials.uppercased()
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview().dividedBy(1.45)
        }
    }
    
    /// Добавляет action на родительский ImageView
    /// - Parameters:
    ///   - target: target
    ///   - action: selector
    func addAction(target: Any?, action: Selector) {
        let button = UIButton(type: .custom)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
