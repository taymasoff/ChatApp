//
//  Constants.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

// MARK: - Colors

enum AppColors: String {
    case appMain
    case appGray
    case appYellow
    case dmGray
    case dmGreen
    case statusGreen
    case barItemGray
    
    var rawValue: String {
        switch self {
        case .appMain:
            return "appMain"
        case .appGray:
            return "appGray"
        case .appYellow:
            return "appYellow"
        case .dmGray:
            return "dmGray"
        case .dmGreen:
            return "dmGreen"
        case .statusGreen:
            return "statusGreen"
        case .barItemGray:
            return "barItemGray"
        }
    }
}

// MARK: - Fonts

enum AppFonts {
    case sfProDisplay
    case sfProText
}

enum FontTypes: String {
    case regular
    case bold
    case semibold
    
    var rawValue: String {
        switch self {
        case .regular: return "Regular"
        case .bold: return "Bold"
        case .semibold: return "Semibold"
        }
    }
}

// MARK: - Images

enum AppImages: String {
    case gear
    case yellowCircle
    
    var rawValue: String {
        switch self {
        case .gear:
            return "gear"
        case .yellowCircle:
            return "yellowCircle"
        }
    }
}

// MARK: - Функции получения

struct AppAssets {
    
    /// Получить изображение из библиотеки асетов
    /// - Parameter image: список доступных изображений типа AppImages
    /// - Returns: опциональное изображение
    static func image(_ image: AppImages) -> UIImage? {
        switch image {
        case .gear:
            return UIImage(named: image.rawValue)
        case .yellowCircle:
            return UIImage(named: image.rawValue)
        }
    }
    
    /// Получить шрифт из библиотеки асетов
    /// - Parameters:
    ///   - font: список доступных шрифтов типа AppFonts
    ///   - type: тип шрифта стандартный/жирный/полужирный
    ///   - size: размер шрифта в формате CGFloat
    /// - Returns: шрифт типа UIFont
    static func font(_ font: AppFonts, type: FontTypes, size: CGFloat) -> UIFont {
        switch font {
        case .sfProDisplay:
            guard let pickedFont = UIFont(name: "SFProDisplay-\(type.rawValue)", size: size) else {
                if type == .bold || type == .semibold {
                    return UIFont.boldSystemFont(ofSize: size)
                } else {
                    return UIFont.systemFont(ofSize: size)
                }
            }
            return pickedFont
        case .sfProText:
            guard let pickedFont = UIFont(name: "SFProText-\(type.rawValue)", size: size) else {
                if type == .bold || type == .semibold {
                    return UIFont.boldSystemFont(ofSize: size)
                } else {
                    return UIFont.systemFont(ofSize: size)
                }
            }
            return pickedFont
        }
    }
    
    /// Получить цвет из библиотеки асетов
    /// - Parameter name: список доступных цветов типа AppColors
    /// - Returns: цвет типа UIColor
    static func colors(_ name: AppColors) -> UIColor {
        switch name {
        case .appMain:
            return UIColor(named: name.rawValue) ?? .white
        case .appGray:
            return UIColor(named: name.rawValue) ?? .lightGray
        case .appYellow:
            return UIColor(named: name.rawValue) ?? .yellow
        case .dmGray:
            return UIColor(named: name.rawValue) ?? .gray
        case .dmGreen:
            return UIColor(named: name.rawValue) ?? .green
        case .statusGreen:
            return UIColor(named: name.rawValue) ?? .systemGreen
        case .barItemGray:
            return UIColor(named: name.rawValue) ?? .lightGray
        }
    }
}
