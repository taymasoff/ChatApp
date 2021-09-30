//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol ProfileViewModelProtocol {
    var router: RouterProtocol { get }
    init(router: RouterProtocol)
    
    var userName: Dynamic<String?> { get set }
    var userDescription: Dynamic<String?> { get set }
    var userAvatar: Dynamic<UIImage?> { get set }
}

final class ProfileViewModel: ProfileViewModelProtocol {
    
    var router: RouterProtocol
    
    var userName: Dynamic<String?> = Dynamic(nil)
    var userDescription: Dynamic<String?> = Dynamic(nil)
    var userAvatar: Dynamic<UIImage?> = Dynamic(nil)
    
    init(router: RouterProtocol) {
        self.router = router
        
        self.userName.value = "Marina Dudarenko"
        self.userDescription.value =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }
}
