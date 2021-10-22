//
//  ProfileViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/// Вью-модель профиля
final class ProfileViewModel: Routable {
    
    let router: MainRouterProtocol
    
    var userName: Dynamic<String?> = Dynamic(nil)
    var userDescription: Dynamic<String?> = Dynamic(nil)
    var userAvatar: Dynamic<UIImage?> = Dynamic(nil)
    
    init(router: MainRouterProtocol) {
        self.router = router
        
        self.userName.value = "Marina Dudarenko"
        self.userDescription.value =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }
    
    func editProfileImagePressed(sender: UIViewController) {
        ImagePickerManager().pickImage(sender) { [weak self] image in
            self?.userAvatar.value = image
        }
    }
    
    func didDismissProfileView() {
        // Action on dismiss
    }
}
