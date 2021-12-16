//
//  UISearchBar+forceTextFieldAppearance.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 21.11.2021.
//

import UIKit

/*
 Цвет плейсхолдера у серч бара фиг поменяешь, поэтому такой костыль
 */

extension UISearchBar {
    
    /// Красит TextField и заменяет лейблу плейсхолдера на новую с тем же текстом, но заданным цветом
    /// - Parameters:
    ///   - textColor: цвет текста внутри текст филда
    ///   - placeholderColor: цвет текста плейсхолдера
    func forceTextFieldAppearance(textColor: UIColor,
                                  placeholderColor: UIColor) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = textColor
        
        if let textFieldInsideSearchBarLabel = textFieldInsideSearchBar?
            .value(forKey: "placeholderLabel") as? UILabel {
            
            let placeholderText = self.placeholder
            
            self.placeholder = " "
            
            let placeholderLabel = UILabel(frame: .zero)
            
            placeholderLabel.text = placeholderText
            placeholderLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
            placeholderLabel.textColor = placeholderColor
            
            textFieldInsideSearchBarLabel.addSubview(placeholderLabel)
            
            placeholderLabel.leadingAnchor.constraint(equalTo: textFieldInsideSearchBarLabel.leadingAnchor).isActive = true
            placeholderLabel.topAnchor.constraint(equalTo: textFieldInsideSearchBarLabel.topAnchor).isActive = true
            placeholderLabel.bottomAnchor.constraint(equalTo: textFieldInsideSearchBarLabel.bottomAnchor).isActive = true
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
            placeholderLabel.setContentCompressionResistancePriority(.defaultHigh,
                                                                     for: .horizontal)
        }
    }
}
