//
//  ConversationCellViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/// Вью-модель ячейки диалога
final class ConversationCellViewModel {
    var profileImage: Dynamic<UIImage?> = Dynamic(nil)
    var profileImageURL: Dynamic<String?> = Dynamic(nil)
    var name: Dynamic<String?> = Dynamic(nil)
    var lastMessage: Dynamic<String?> = Dynamic(nil)
    var date: Dynamic<String?> = Dynamic(nil)
    var isOnline: Dynamic<Bool?> = Dynamic(nil)
    var hasUnreadMessages: Dynamic<Bool?> = Dynamic(nil)
    
    init(with conversation: Conversation? = nil) {
        updateValues(with: conversation)
    }
    
    private func updateValues(with conversation: Conversation?) {
        profileImageURL.value = conversation?.profileImageURL
        isOnline.value = conversation?.isOnline
        name.value = conversation?.userName
        lastMessage.value = conversation?.lastMessage
        
        // Тут преобразовываем дату и время из модели, пока мок
        let mockDate = Date().addingTimeInterval(TimeInterval(Int.random(in: -100000...0)))
        date.value = mockDate.timeSince()
        
        hasUnreadMessages.value = conversation?.hasUnreadMessages
        
        let mockImages: [UIImage?] = [UIImage(named: "ArthurBell"),
                                      UIImage(named: "JaneWarren"), nil]
        profileImage.value = mockImages.randomElement()!
    }
}
