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
                              dialogueID: String,
                              chatName: String?,
                              chatImage: UIImage?)
    func presentThemesViewController(onThemeChanged: @escaping (UIColor) -> Void)
    func presentThemesViewControllerObjc(delegate: ThemesViewControllerDelegate)
    func presentProfileViewController(delegate: ProfileDelegate?)
    func popToRoot(animated: Bool)
    func presentAlert(_ alert: UIAlertController, animated: Bool)
    func resetToUpdateTheme()
}

class MainRouter: MainRouterProtocol {
    var navigationController: UINavigationController?
    let appAssembler: AppAssembler
    
    init(navigationController: UINavigationController, appAssembler: AppAssembler) {
        self.navigationController = navigationController
        self.appAssembler = appAssembler
    }
    
    /// Инициализировать первый экран приложения
    func initiateFirstViewController() {
        if let navigationController = navigationController {
            let conversationsViewController = appAssembler.container.resolve(
                type: ConversationsViewController.self
            ) as ConversationsViewController
            navigationController.viewControllers = [conversationsViewController]
        }
    }
    
    /// Инициализировать и закинуть в navigation стэк экран переписки
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func showDMViewController(animated: Bool = true,
                              dialogueID: String,
                              chatName: String?,
                              chatImage: UIImage?) {
        if let navigationController = navigationController {
            appAssembler.assembleDMModule(dialogueID: dialogueID,
                                          chatName: chatName,
                                          chatImage: chatImage)
            let dmViewController = appAssembler.container.resolve(
                type: DMViewController.self
            ) as DMViewController
            navigationController.pushViewController(dmViewController,
                                                    animated: animated)
        }
    }
    
    /// Инициализировать и представить модально экран выбора тем (Swift)
    func presentThemesViewController(onThemeChanged: @escaping (UIColor) -> Void) {
        if let navigationController = navigationController {
            appAssembler.assembleThemesModule(onThemeChanged: onThemeChanged)
            let themesViewController = appAssembler.container.resolve(
                type: ThemesViewController.self
            ) as ThemesViewController
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
    func presentProfileViewController(delegate: ProfileDelegate? = nil) {
        if let navigationController = navigationController {
            appAssembler.assembleProfileModule(delegate: delegate)
            let profileViewController = appAssembler.container.resolve(
                type: ProfileViewController.self
            ) as ProfileViewController
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
