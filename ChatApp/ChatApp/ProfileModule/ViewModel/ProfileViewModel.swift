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
        
        self.userName.value = nil
        self.userDescription.value = nil
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
