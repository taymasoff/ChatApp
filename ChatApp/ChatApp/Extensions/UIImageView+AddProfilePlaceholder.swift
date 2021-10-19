//
//  UIImageView+AddProfilePlaceholder.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.09.2021.
//

import UIKit
import SnapKit
import Rswift

/*
 👉 Добавляет в UIImageView желтый фон с инициалами, как в приложении тинькова.
 ⚙️ Использование: imageView.addProfilePlaceholder(fullName: "Oleg Tinkoff") -> OT
 */

extension UIImageView {
    
    /// Добавляет желтый фон с инициалами на родительский ImageView
    /// - Parameter fullName: Имя Фамилия
    func addProfilePlaceholder(fullName: String?,
                               formattedBy formatter: PersonNameComponentsFormatter = PersonNameComponentsFormatter()) {
        guard let fullName = fullName,
              let components = formatter.personNameComponents(from: fullName) else {
                  showPlaceholder("?")
                  return
              }
        
        formatter.style = .abbreviated
        let initials = formatter.string(from: components)
        addProfilePlaceholder(initials: initials)
    }
    
    /// Добавляет желтый фон с инициалами на родительский ImageView
    /// - Parameter initials: Инициалы (Например: "ОТ")
    func addProfilePlaceholder(initials: String?) {
        guard let initials = initials,
              initials.count >= 1 && initials.count < 5 else {
                  Log.error("Введены пустые инициалы, или размер не соответствует формуле 1<=X<5 ")
                  showPlaceholder("?")
                  return
              }
        showPlaceholder(initials)
    }
    
    private func showPlaceholder(_ initials: String) {
        // Если у нас уже установлен placeholder, удаляем предыдущие инициалы
        if let initialsLabel = self.subviews.last as? UILabel {
            initialsLabel.removeFromSuperview()
        }
        self.image = R.image.yellowCircle()
        let label = UILabel()
        // Тут магия по уменьшению шрифта так, чтобы он вписывался в лейбу
        label.font = UIFont.systemFont(ofSize: 120, weight: .semibold)
        label.textColor = .black
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
        let button = UIButton(type: .system)
        button.addTarget(target, action: action, for: .touchUpInside)
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
