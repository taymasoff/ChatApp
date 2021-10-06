//
//  DMViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import Foundation
import UIKit

protocol DMViewModelProtocol {
    var router: RouterProtocol { get }
    var chatBuddyName: Dynamic<String?> { get set }
    var chatBuddyImageURL: Dynamic<String?> { get set }
    var chatBuddyImage: Dynamic<UIImage?> { get }
    
    init(router: RouterProtocol, chatBuddyName: String?, chatBuddyImageURL: String?)
}

final class DMViewModel: DMViewModelProtocol {
    
    var router: RouterProtocol
    var chatBuddyName: Dynamic<String?> = Dynamic(nil)
    var chatBuddyImageURL: Dynamic<String?> = Dynamic(nil)
    var chatBuddyImage: Dynamic<UIImage?> = Dynamic(nil)
    
    init(router: RouterProtocol, chatBuddyName: String? = nil, chatBuddyImageURL: String? = nil) {
        self.router = router
        self.chatBuddyName.value = chatBuddyName
        self.chatBuddyImageURL.value = chatBuddyImageURL
        
        observeImageURL()
    }
    
    private func observeImageURL() {
        self.chatBuddyImageURL.bind { [unowned self] url in
            if let _ = url {
                // получаем пикчу, пока мок
                let mockImages: [UIImage?] = [UIImage(named: "ArthurBell"), UIImage(named: "JaneWarren"), nil]
                chatBuddyImage.value = mockImages.randomElement()!
            }
        }
    }
}
