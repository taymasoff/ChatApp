//
//  UIButton+setBackgroundForState.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 23.10.2021.
//

import UIKit

/*
 👉 Возможность менять backgroundColor для определенного состояния кнопки
    Необходимо для возможности ставить цвет для .highlighted состояния,
    чтобы имитировать анимацию нажатия кастомной кнопки
 */

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
            color.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        }
        setBackgroundImage(colorImage, for: state)
    }
}
