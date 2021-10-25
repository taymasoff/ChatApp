//
//  ConversationCellViewModel.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.09.2021.
//

import UIKit

/// Вью-модель ячейки диалога
final class ConversationCellViewModel {
    let conversationImage: Dynamic<UIImage?> = Dynamic(nil)
    let name: Dynamic<String?> = Dynamic(nil)
    let lastMessage: Dynamic<String?> = Dynamic(nil)
    let lastActivity: Dynamic<String?> = Dynamic(nil)
    let isActive: Dynamic<Bool?> = Dynamic(nil)
    
    init(with conversation: Conversation? = nil) {
        updateValues(with: conversation)
    }
    
    private func updateValues(with conversation: Conversation?) {
        // Пока в модели нет изображения, всегда nil
        self.conversationImage.value = nil
        self.name.value = conversation?.name
        self.lastMessage.value = conversation?.lastMessage
        self.lastActivity.value = conversation?.lastActivity?.timeSince()
        self.isActive.value = conversation?.isActive
    }
}
