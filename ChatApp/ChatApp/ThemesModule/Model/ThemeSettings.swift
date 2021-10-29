//
//  ThemeSettings.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 13.10.2021.
//

import UIKit
import Rswift

/// Настройки тем
struct ThemeSettings {
    
    /// Цвет фона элементов
    let backGroundColor: UIColor
    
    /// Цвет окна приложения
    let mainColor: UIColor
    
    /// Дополнительный цвет
    let secondaryColor: UIColor
    
    /// Светлый ли фон
    private let isLight: Bool
    
    /// UIBarStyle -> Светлый или Темный в зависимости от темы
    let barStyle: UIBarStyle
    
    /// Цвет кнопок
    let tintColor: UIColor
    
    /// Цвет основного текста
    var titleTextColor: UIColor
    
    /// Цвет вспомогательного текста
    var subtitleTextColor: UIColor
    
    /// Констрастный цвет к tintу
    var tintContrastColor: UIColor
    
    init(backGroundColor: UIColor, mainColor: UIColor?, secondaryColor: UIColor? = nil, tintColor: UIColor, titleTextColor: UIColor? = nil, subtitleTextColor: UIColor? = nil) {
        self.backGroundColor = backGroundColor
        self.mainColor = mainColor ?? backGroundColor.lighter(by: 15)
        self.secondaryColor = secondaryColor ?? backGroundColor
        self.isLight = backGroundColor.isLight()
        self.barStyle = isLight ? UIBarStyle.default : UIBarStyle.black
        self.tintColor = tintColor
        self.titleTextColor = titleTextColor ?? backGroundColor.contrastingColor(for: .title)
        self.subtitleTextColor = subtitleTextColor ?? backGroundColor.contrastingColor(for: .subtitle)
        self.tintContrastColor = self.tintColor.contrastingColor(for: .title)
    }
    
    static let defaultLight = ThemeSettings(backGroundColor: R.color.appGray()!,
                                            mainColor: R.color.appMain()!,
                                            tintColor: UIColor.systemBlue)
    static let darkAndWhite = ThemeSettings(backGroundColor: R.color.darkBg()!,
                                            mainColor: R.color.darkMain()!,
                                            tintColor: R.color.darkTint()!)
    static let charcoal = ThemeSettings(backGroundColor: R.color.charcoalMain()!,
                                        mainColor: R.color.charcoalBg()!,
                                        secondaryColor: R.color.charcoalSecondary()!,
                                        tintColor: R.color.appYellow()!,
                                        titleTextColor: .white,
                                        subtitleTextColor: UIColor.init(white: 1.0, alpha: 0.6))
    static let imperialRed = ThemeSettings(backGroundColor: R.color.imperialBg()!,
                                           mainColor: R.color.imperialMain()!,
                                           secondaryColor: R.color.imperialSecondary()!,
                                           tintColor: UIColor.systemBlue,
                                           titleTextColor: .black,
                                           subtitleTextColor: UIColor.init(white: 0.0, alpha: 0.6))
}
