//
//  Router.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit
import Rswift

protocol RouterProtocol {
    var navigationController: UINavigationController? { get }
}

protocol MainRouterProtocol: RouterProtocol {
    func initiateFirstViewController()
    func showDMViewController(animated: Bool,
                              withViewModel viewModel: DMViewModel?)
    func presentThemesViewController(onThemeChanged: @escaping (UIColor) -> Void)
    func presentThemesViewControllerObjc(delegate: ThemesViewControllerDelegate)
    func presentProfileViewController()
    func popToRoot(animated: Bool)
    func presentAlert(_ alert: UIAlertController, animated: Bool)
    func resetToUpdateTheme()
}

class MainRouter: MainRouterProtocol {
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    /// Инициализировать первый экран приложения
    func initiateFirstViewController() {
        if let navigationController = navigationController {
            let conversationsViewModel = ConversationsViewModel(router: self)
            let conversationsViewController = ConversationsViewController(with: conversationsViewModel)
            navigationController.viewControllers = [conversationsViewController]
        }
    }
    
    /// Инициализировать и закинуть в navigation стэк экран переписки
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func showDMViewController(animated: Bool = true,
                              withViewModel viewModel: DMViewModel? = nil) {
        if let navigationController = navigationController {
            let dmViewController: DMViewController
            if let viewModel = viewModel {
                dmViewController = DMViewController(with: viewModel)
            } else {
                let viewModel = DMViewModel(router: self)
                dmViewController = DMViewController(with: viewModel)
            }
            navigationController.pushViewController(dmViewController,
                                                    animated: animated)
        }
    }
    
    /// Инициализировать и представить модально экран выбора тем (Swift)
    func presentThemesViewController(onThemeChanged: @escaping (UIColor) -> Void) {
        if let navigationController = navigationController {
            let themesViewModel = ThemesViewModel(router: self,
                                                  onThemeChanged: onThemeChanged)
            let themesViewController = ThemesViewController(with: themesViewModel)
            // Представляем модально с прозрачным эффектом
            themesViewController.modalPresentationStyle = .overCurrentContext
            navigationController.present(themesViewController,
                                         animated: false,
                                         completion: nil)
        }
    }
    
    /// Инициализировать и представить модально экран тем на ObjectiveC
    func presentThemesViewControllerObjc(delegate: ThemesViewControllerDelegate) {
        if let navigationController = navigationController {
            guard let themesNavController = R.storyboard
                    .themesViewControllerObjc
                    .instantiateInitialViewController() else { return }
            if let themesVC = themesNavController.topViewController as? ThemesViewControllerObjc {
                themesVC.setDelegate(delegate)
            }
            navigationController.present(themesNavController,
                                         animated: true,
                                         completion: nil)
        }
    }
    
    /// Инициализировать и представить модально экран профиля в своем собственном NC
    func presentProfileViewController() {
        if let navigationController = navigationController {
            let fileManager = AsyncFileManager(fileManager: FileManager.default, asyncHandler: .gcd, qos: .userInitiated)
            let fileManagerPreferences = FileManagerPreferences(
                preferredTextExtension: .txt,
                preferredImageExtension: .jpeg,
                preferredDirectory: .userProfile
            )
            let persistenceManager = PersistenceManager(
                storageType: .fileManger(fileManager, fileManagerPreferences)
            )
            let profileViewModel = ProfileViewModel(router: self,
                                                    persistenceManager: persistenceManager)
            let profileViewController = ProfileViewController(with: profileViewModel)
            // Представляем модально с прозрачным эффектом
            profileViewController.modalPresentationStyle = .overCurrentContext
            navigationController.present(profileViewController,
                                         animated: false,
                                         completion: nil)
        }
    }
    
    /// Вернуться к первому экрану
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func popToRoot(animated: Bool = true) {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: animated)
        }
    }
    
    /// Модально представить UIAlertController на видимом ViewController'е
    /// - Parameters:
    ///   - alert: UIAlertController
    ///   - animated: включена ли анимация
    func presentAlert(_ alert: UIAlertController, animated: Bool = true) {
        if let navigationController = navigationController {
            navigationController.visibleViewController?.present(alert, animated: animated)
        }
    }
    
    /// Костыль, чтобы перерисовать UI и обновить тему
    func resetToUpdateTheme() {
        if #available(iOS 13, *) {
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            updateApp(keyWindow)
        } else {
            let keyWindow = UIApplication.shared.keyWindow
            updateApp(keyWindow)
        }
        
        func updateApp(_ keyWindow: UIWindow?) {
            // Создаем ConversationsVC вставляем его в навигейшн стэк как единственный элемент
            initiateFirstViewController()
            // Применяем новую тему на UIWindow
            keyWindow?.backgroundColor = ThemeManager.currentTheme.settings.mainColor
            // Обновляем иерархию, чтобы UINavigationController проснулся и обновил свой appearance
            keyWindow?.subviews.forEach { view in
                view.removeFromSuperview()
                keyWindow?.addSubview(view)
            }
        }
    }
}
