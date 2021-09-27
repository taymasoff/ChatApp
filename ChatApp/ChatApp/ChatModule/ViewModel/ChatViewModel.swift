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
}

final class ChatViewModel: ChatViewModelProtocol {
    
    var router: MainRouterProtocol?
    
    init(router: MainRouterProtocol) {
        self.router = router
    }
}
