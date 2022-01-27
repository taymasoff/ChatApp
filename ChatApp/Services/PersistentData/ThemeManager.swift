//
//  ThemeManager.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 13.10.2021.
//

import UIKit

struct ThemeManager {
    static let themeKey = "AppTheme"
    
    // Использую 2 проперти темы, чтобы иметь возможность изменить тему на следующий сеанс, но оставить текущую на этот
    private(set) static var currentTheme: Theme = Theme.defaultLight {
        didSet {
            applyTheme()
        }
    }
    
    @StoredProperty(ThemeManager.themeKey, defaultValue: Theme.defaultLight)
    static var storedTheme: Theme
    
    static func updateCurrentTheme() {
        currentTheme = storedTheme
    }
    
    private static func applyTheme(_ theme: Theme = currentTheme) {
        // MARK: Window
        UIApplication.shared.delegate?.window??.tintColor = theme.settings.mainColor
        // MARK: TabBar Style
        UITabBar.appearance().barStyle = theme.settings.barStyle
        // MARK: TableView Style
        UITableViewCell.appearance().backgroundColor = .clear
        // MARK: Navigation Appearance
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [
                .foregroundColor: theme.settings.titleTextColor,
                .font: UIFont.systemFont(ofSize: 30,
                                         weight: .bold)
            ]
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: theme.settings.titleTextColor,
                .font: UIFont.systemFont(ofSize: 18,
                                         weight: .semibold)
            ]
            navBarAppearance.backgroundColor = theme.settings.backGroundColor
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().tintColor = theme.settings.tintColor
        } else {
            UINavigationBar.appearance().barStyle = theme.settings.barStyle
            UINavigationBar.appearance().barTintColor = theme.settings.backGroundColor
            UINavigationBar.appearance().tintColor = theme.settings.tintColor
            UINavigationBar.appearance().isTranslucent = false
        }
    }
}
