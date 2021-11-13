//
//  UIColor+contrastringColor.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 12.10.2021.
//

import UIKit

/*
 👉 Функция для нахождения подходящего цвета текста для фона,
    т.е если фон темный - цвет белый или наоборот.
 ⚙️ Алгоритм: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
 */

extension UIColor {
    
    enum TextType {
        case title
        case subtitle
    }
    
    /// Найти контрастный цвет к выбранному цвету
    /// - Parameters:
    ///   - textType: тип текста (основной/вспомогательный)
    /// - Returns: Рекомендуемый цвет шрифта (белый/черный или их версии с пониженной прозрачностью)
    func contrastingColor(for textType: TextType? = nil) -> UIColor {
        
        let color = self
        
        let isTitle = textType != .subtitle ? true : false
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000
        if brightness < 0.5 {
            return isTitle ? UIColor.white : UIColor(white: 1.0, alpha: 0.6)
        } else {
            return isTitle ? UIColor.black : UIColor(white: 0.0, alpha: 0.6)
        }
    }
    
    /// Найти контрастный цвет к выбранному цвету
    /// - Parameters:
    ///   - color: цвет фона, на котором будет текст
    ///   - textType: тип текста (основной/вспомогательный)
    /// - Returns: Рекомендуемый цвет шрифта (белый/черный или их версии с пониженной прозрачностью)
    static func contrastingColor(to color: UIColor,
                                 for textType: TextType? = nil) -> UIColor {
        
        let isTitle = textType != .subtitle ? true : false
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000
        if brightness < 0.5 {
            return isTitle ? UIColor.white : UIColor(white: 1.0, alpha: 0.6)
        } else {
            return isTitle ? UIColor.black : UIColor(white: 0.0, alpha: 0.6)
        }
    }
}
