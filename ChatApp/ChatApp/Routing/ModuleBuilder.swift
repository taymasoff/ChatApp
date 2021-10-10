//
//  ModuleBuilder.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol ModuleBuilderProtocol {
    func createChatModule(router: MainRouterProtocol) -> UIViewController
    func createDMModule(router: MainRouterProtocol) -> UIViewController
    func createProfileModule(router: MainRouterProtocol) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    
    func createChatModule(router: MainRouterProtocol) -> UIViewController {
        let vc = ChatViewController()
        let viewModel = ChatViewModel(router: router)
        vc.viewModel = viewModel
        return vc
    }
    
    func createDMModule(router: MainRouterProtocol) -> UIViewController {
        let vc = DMViewController()
        let viewModel = DMViewModel(router: router)
        vc.viewModel = viewModel
        return vc
    }
    
    func createProfileModule(router: MainRouterProtocol) -> UIViewController {
        let vc = ProfileViewController()
        let viewModel = ProfileViewModel(router: router)
        vc.viewModel = viewModel
        return vc
    }
}
