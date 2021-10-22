//
//  Theme.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 11.10.2021.
//

import UIKit

enum Theme: String, CaseIterable {

    case defaultLight = "Default Light"
    case darkAndWhite = "Dark and White"
    case charcoal = "Charcoal"
    case imperialRed = "Imperial Red"
    
    /// Настройки темы
    var settings: ThemeSettings {
        switch self {
        case .defaultLight:
            return ThemeSettings.defaultLight
        case .darkAndWhite:
            return ThemeSettings.darkAndWhite
        case .charcoal:
            return ThemeSettings.charcoal
        case .imperialRed:
            return ThemeSettings.imperialRed
        }
    }
}


