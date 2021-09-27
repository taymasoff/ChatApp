//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation

protocol ProfileViewModelProtocol {
    var router: RouterProtocol { get }
    init(router: RouterProtocol)
}

final class ProfileViewModel: ProfileViewModelProtocol {
    
    var router: RouterProtocol
    
    init(router: RouterProtocol) {
        self.router = router
    }
}
