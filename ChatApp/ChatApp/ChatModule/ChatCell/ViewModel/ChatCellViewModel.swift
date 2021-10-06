//
//  ChatCellViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

protocol ChatCellViewModelProtocol {
    var profileImage: Dynamic<UIImage?> { get set }
    var profileImageURL: Dynamic<String?> { get set }
    var name: Dynamic<String?> { get set }
    var lastMessage: Dynamic<String?> { get set }
    var date: Dynamic<String?> { get set }
    var isOnline: Dynamic<Bool?> { get set }
    var hasUnreadMessages: Dynamic<Bool?> { get set }
    
    func configure(_ conversation: ConversationViewDataType)
}

class ChatCellViewModel: ChatCellViewModelProtocol {
    var profileImage: Dynamic<UIImage?> = Dynamic(nil)
    var profileImageURL: Dynamic<String?> = Dynamic(nil)
    var name: Dynamic<String?> = Dynamic(nil)
    var lastMessage: Dynamic<String?> = Dynamic(nil)
    var date: Dynamic<String?> = Dynamic(nil)
    var isOnline: Dynamic<Bool?> = Dynamic(nil)
    var hasUnreadMessages: Dynamic<Bool?> = Dynamic(nil)
    
    func configure(_ conversation: ConversationViewDataType) {
        name.value = conversation.userName
        lastMessage.value = conversation.lastMessage
        date.value = conversation.messageDate + " →"
        isOnline.value = conversation.isOnline
        hasUnreadMessages.value = conversation.hasUnreadMessages
        profileImageURL.value = conversation.profileImageURL
        
        let mockImages: [UIImage?] = [UIImage(named: "ArthurBell"), UIImage(named: "JaneWarren"), nil]
        profileImage.value = mockImages.randomElement()!
    }
}
