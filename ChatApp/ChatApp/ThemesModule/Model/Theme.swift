//
//  Theme.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 11.10.2021.
//

import UIKit

enum Theme: String, CaseIterable, Codable {

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
    
    /// Какой индекс выбран
    var selectedIndex: Int {
        switch self {
        case .defaultLight:
            return 0
        case .darkAndWhite:
            return 1
        case .charcoal:
            return 2
        case .imperialRed:
            return 3
        }
    }
}


