//
//  ThemesModuleAssembler.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 13.11.2021.
//

import UIKit

/// Сборщик компонентов модуля выбора тем
class ThemesModuleAssembler {
    
    struct Configuration {
        let onThemeChanged: (UIColor) -> Void
    }
    
    private let configuration: Configuration
    let container: DIContainer
    
    init(container: DIContainer,
         configuration: ThemesModuleAssembler.Configuration) {
        self.container = container
        self.configuration = configuration
    }
    
    func assembleAll() {
        assembleViewModel()
        assembleThemesView()
        assembleViewController()
    }
    
    func assembleViewController() {
        container.register(type: ThemesViewController.self) { container in
            return ThemesViewController(
                with: container.resolve(type: ThemesViewModel.self),
                themesView: container.resolve(type: ThemesView.self)
            )
        }
    }
    
    func assembleThemesView() {
        container.register(type: ThemesView.self) { _ in
            return ThemesView()
        }
    }
    
    func assembleViewModel() {
        container.register(type: ThemesViewModel.self) { container in
            return ThemesViewModel(
                router: container.resolve(type: MainRouter.self, asSingleton: true),
                onThemeChanged: self.configuration.onThemeChanged
            )
        }
    }
}
