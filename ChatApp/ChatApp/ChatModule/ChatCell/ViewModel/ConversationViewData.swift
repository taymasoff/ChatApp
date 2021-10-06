//
//  ConversationViewData.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import UIKit

/*
 👉 Модель представления Conversation
 */

protocol ConversationViewDataType {
    var profileImageURL: String? { get }
    var isOnline: Bool { get }
    var userName: String? { get }
    var lastMessage: String? { get }
    var messageDate: String { get }
    var hasUnreadMessages: Bool { get }
}

struct ConversationViewData: ConversationViewDataType {
    var profileImageURL: String? {
        return conversation.profileImageURL
    }
    
    var isOnline: Bool {
        return conversation.isOnline
    }
    
    var userName: String? {
        return conversation.userName
    }
    
    var lastMessage: String? {
        return conversation.lastMessage
    }
    
    var messageDate: String {
        // Пока не знаю в каком формате будет дата и время в модели.
        // Идея преобразовать все это в Date(), а потом от туда вытащить отформатированное значение
        // в виде интервала с помощью функции timeSince в расширении Date
//        let dateStr = conversation.messageDate
//        let timeStr = conversation.messageTime
        
        // Пока что ставим рандомную моковую дату
        let date = Date().addingTimeInterval(TimeInterval(Int.random(in: -100000...0)))
        return date.timeSince()
    }
    
    var hasUnreadMessages: Bool {
        guard let hasUnread = conversation.hasUnreadMessages else {
            Log.error("Conversation returns nil for hasUnreadMessages")
            return false
        }
        return hasUnread
    }
    
    private let conversation: Conversation
    
    init(conversation: Conversation) {
        self.conversation = conversation
    }
}
