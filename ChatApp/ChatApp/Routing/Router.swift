//
//  Router.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol RouterProtocol {
    var navigationController: UINavigationController? { get set }
    var moduleBuilder: ModuleBuilderProtocol? { get set }
}

protocol MainRouterProtocol: RouterProtocol {
    func initiateFirstViewController()
    func showDMViewController(animated: Bool)
    func presentProfileViewController()
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
            guard let conversationsViewController = moduleBuilder?.createConversationsModule(router: self) else {
                Log.error("Cannot create Chat Module")
                return
            }
            navigationController.viewControllers = [conversationsViewController]
        }
    }
    
    /// Инициализировать и закинуть в navigation стэк экран переписки
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func showDMViewController(animated: Bool = true) {
        if let navigationController = navigationController {
            guard let dmViewController = moduleBuilder?.createDMModule(router: self) else {
                Log.error("Cannot create DM Module")
                return
            }
            navigationController.pushViewController(dmViewController,
                                                    animated: animated)
        }
    }
    
    /// Инициализировать и представить модально экран профиля в своем собственном NC
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func presentProfileViewController() {
        if let navigationController = navigationController {
            guard let profileViewController = moduleBuilder?.createProfileModule(router: self) else {
                Log.error("Cannot create Profile Module")
                return
            }
            // Представляем модально с прозрачным эффектом
            profileViewController.modalPresentationStyle = .overCurrentContext
            navigationController.present(profileViewController, animated: false, completion: nil)
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
