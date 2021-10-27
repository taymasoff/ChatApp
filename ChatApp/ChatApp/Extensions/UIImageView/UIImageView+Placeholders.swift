//
//  UIImageView+Placeholders.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 29.09.2021.
//

import UIKit
import SnapKit
import Rswift

/*
 👉 Добавляет в UIImageView фон с инициалами группы/человека.
 ⚙️ Использование: imageView.addPlaceholder(name: "Oleg Tinkoff", .forPerson) -> OT
 */

enum PlaceholderType {
    case forPerson
    case forGroupChat
    
    var image: UIImage? {
        switch self {
        case .forPerson:
            return R.image.yellowCircle()
        case .forGroupChat:
            return R.image.blueCircle()
        }
    }
}

internal extension UIImageView {
    
    /// Добавляет желтый фон с инициалами на родительский ImageView
    /// - Parameter fullName: Имя Фамилия
    func addProfilePlaceholder(
        fullName: String?,
        formattedBy formatter: PersonNameComponentsFormatter = PersonNameComponentsFormatter()
    ) {
        guard let fullName = fullName, fullName != "" else {
            setPlaceholder("?", .forPerson)
            return
        }
        
        let initials = getNameInitials(fullName,
                                       formatter: formatter,
                                       formatterStyle: .abbreviated)
        
        addPlaceholder(initials, .forPerson)
    }
    
    func addAbbreviatedPlaceholder(text: String?) {
        guard let text = text, text != "" else {
            setPlaceholder("?", .forGroupChat)
            return
        }
        
        let initials = getAbbreviation(text)
        
        addPlaceholder(initials, .forGroupChat)
    }
    
    // PersonNameComponentsFormatter может получить инициалы только с английского
    // и еще нескольких языков, в котором конечно же нету русского, поэтому
    // если возвращает пустоту - достаем вручную
    private func getNameInitials(
        _ name: String,
        formatter: PersonNameComponentsFormatter,
        formatterStyle: PersonNameComponentsFormatter.Style
    ) -> String {
        
        formatter.style = formatterStyle
        
        if let components = formatter.personNameComponents(from: name) {
            return formatter.string(from: components)
        } else {
            var initials = name.split { !$0.isLetter }
                .reduce(into: "") {
                    if let first = $1.first {
                        $0.append(first)
                    }
                }
            if initials.count > 2,
               let first = initials.first,
               let last = initials.last {
                initials = "\(first)\(last)"
            }
            return initials
        }
    }
    
    // Получаем инициалы с текста (просто
    private func getAbbreviation(_ text: String) -> String {
        return text.split { !$0.isLetter }
        .prefix(3)
        .reduce(into: "") {
            if let first = $1.first {
                $0.append(first)
            }
        }
    }
    
    // Проверяем количество инициалов: от 1 до 3 выводим, больше или 0 вопросик
    private func addPlaceholder(_ initials: String?, _ type: PlaceholderType) {
        if let initials = initials,
              initials.count > 0 && initials.count < 4 {
            setPlaceholder(initials, type)
        } else {
            setPlaceholder("?", type)
        }
    }
}

// MARK: - SetPlaceholder
internal extension UIImageView {
    fileprivate func setPlaceholder(_ initials: String, _ type: PlaceholderType) {
        // Если у нас уже установлен placeholder, удаляем предыдущие инициалы
        if let initialsLabel = self.subviews.last as? UILabel {
            initialsLabel.removeFromSuperview()
        }
        
        self.image = type.image
        
        let label = UILabel(frame: self.frame)
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview().dividedBy(1.45)
        }
        
        layoutIfNeeded()
        
        // Тут магия по уменьшению шрифта так, чтобы он вписывался в лейбу
        label.font = UIFont.systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        // Не знаю почему, но если поставить количество строк 1 и не выставить lineBreakMode шрифт не уменьшается меньше определенного значения
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = initials.uppercased()
    }
}
