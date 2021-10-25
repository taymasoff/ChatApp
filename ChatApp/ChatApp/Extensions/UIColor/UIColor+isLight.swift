//
//  UIColor+isLight.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.10.2021.
//

/*
 👉 Функция для определения яркости цвета
 ⚙️ Алгоритм: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
 */

import UIKit

extension UIColor {
    func isLight() -> Bool {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let brightness = ((r * 299) + (g * 587) + (b * 114)) / 1_000
        return brightness >= 0.5
    }
}
