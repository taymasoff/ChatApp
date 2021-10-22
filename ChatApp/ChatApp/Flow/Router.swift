//
//  Router.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol RouterProtocol {
    var navigationController: UINavigationController? { get }
}

protocol MainRouterProtocol: RouterProtocol {
    func initiateFirstViewController()
    func showDMViewController(animated: Bool,
                              withViewModel viewModel: DMViewModel?)
    func presentProfileViewController()
    func popToRoot(animated: Bool)
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
    
    /// Инициализировать и представить модально экран профиля в своем собственном NC
    /// - Parameter animated: включена ли анимация перехода (да по умолчанию)
    func presentProfileViewController() {
        if let navigationController = navigationController {
            let profileViewModel = ProfileViewModel(router: self)
            let profileViewController = ProfileViewController(with: profileViewModel)
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
