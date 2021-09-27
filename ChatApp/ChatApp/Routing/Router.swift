//
//  Router.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/*
 👉 Простая реализация паттерна Координатор. Отвечает за логику роутинга в приложении.
 */

protocol RouterProtocol {
    var navigationController: UINavigationController? { get set }
    var moduleBuilder: ModuleBuilderProtocol? { get set }
}

protocol MainRouterProtocol: RouterProtocol {
    func initiateFirstViewController()
    func showDMViewController(animated: Bool)
    func showProfileViewController(animated: Bool)
    func popToRoot(animated: Bool)
}

class MainRouter: MainRouterProtocol {
    var navigationController: UINavigationController?
    var moduleBuilder: ModuleBuilderProtocol?
    
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    
    /// Инициализировать первый экран приложения
    func initiateFirstViewController() {
        if let navigationController = navigationController {
            guard let toDoViewController = moduleBuilder?.createChatModule(router: self) else {
                Log.info("Cannot create Chat Module")
                return
            }
            navigationController.viewControllers = [toDoViewController]
        }
    }
    
    /// Инициализировать и закинуть в navigation стэк экран переписки
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func showDMViewController(animated: Bool = true) {
        if let navigationController = navigationController {
            guard let dmViewController = moduleBuilder?.createDMModule(router: self) else {
                Log.info("Cannot create DM Module")
                return
            }
            navigationController.pushViewController(dmViewController,
                                                    animated: animated)
        }
    }
    
    /// Инициализировать и представить модально экран профиля в своем собственном NC
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func showProfileViewController(animated: Bool = true) {
        if let navigationController = navigationController {
            guard let profileViewController = moduleBuilder?.createProfileModule(router: self) else {
                Log.info("Cannot create Profile Module")
                return
            }
            // Еще один navigation controller создается для того, чтобы модальное представление ProfileViewController имело свой navigationBar, как в дизайне
            let emptyNav = UINavigationController(rootViewController: profileViewController)
            navigationController.present(emptyNav, animated: true, completion: nil)
        }
    }
    
    /// Вернуться к первому экрану
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func popToRoot(animated: Bool = true) {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: animated)
        }
    }
}
