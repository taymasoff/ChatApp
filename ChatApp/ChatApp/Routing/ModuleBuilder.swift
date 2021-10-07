//
//  ModuleBuilder.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol ModuleBuilderProtocol {
    func createConversationsModule(router: MainRouterProtocol) -> UIViewController
    func createDMModule(router: MainRouterProtocol, withViewModel viewModel: DMViewModelProtocol?) -> UIViewController
    func createProfileModule(router: MainRouterProtocol) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    
    func createConversationsModule(router: MainRouterProtocol) -> UIViewController {
        let vc = ConversationsViewController()
        let viewModel = ConversationsViewModel(router: router)
        vc.viewModel = viewModel
        return vc
    }
    
    func createDMModule(router: MainRouterProtocol,
                        withViewModel viewModel: DMViewModelProtocol? = nil) -> UIViewController {
        let vc = DMViewController()
        if let viewModel = viewModel {
            vc.viewModel = viewModel
        } else {
            vc.viewModel = DMViewModel(router: router)
        }
        return vc
    }
    
    func createProfileModule(router: MainRouterProtocol) -> UIViewController {
        let vc = ProfileViewController()
        let viewModel = ProfileViewModel(router: router)
        vc.viewModel = viewModel
        return vc
    }
}
