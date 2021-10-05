//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation

protocol ChatViewModelProtocol {
    var router: MainRouterProtocol? { get }
    init(router: MainRouterProtocol)
    
    func profileBarButtonPressed()
    func gearBarButtonPressed()
}

final class ChatViewModel: ChatViewModelProtocol {
    
    var router: MainRouterProtocol?
    
    init(router: MainRouterProtocol) {
        self.router = router
    }
    
    func profileBarButtonPressed() {
        router?.presentProfileViewController()
    }
    
    func gearBarButtonPressed() {
        // Обработка нажатия на левый BarButton
    }
}
