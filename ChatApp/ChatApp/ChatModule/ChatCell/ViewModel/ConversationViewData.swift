//
//  ConversationViewData.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import UIKit

/*
 👉 Модель представления Conversation в ChatCell
 */

protocol ConversationViewDataType {
    var profileImage: UIImage? { get }
    var isOnline: Bool { get }
    var userName: String { get }
    var lastMessage: String { get }
    var messageDate: String { get }
    var hasUnreadMessages: Bool { get }
}

struct ConversationViewData: ConversationViewDataType {
    var profileImage: UIImage? {
        // Тут над как-то получить пикчу потом
        return nil
    }
    
    var isOnline: Bool {
        return conversation.isOnline
    }
    
    var userName: String {
        guard let userName = conversation.userName else {
            Log.error("Conversation returns nil for username")
            return ""
        }
        return userName
    }
    
    var lastMessage: String {
        guard let lastMessage = conversation.lastMessage else {
            return "Новых сообщений нет!"
        }
        return lastMessage
    }
    
    var messageDate: String {
        // Пока не знаю в каком формате будет дата и время в модели.
        // Идея преобразовать все это в Date(), а потом от туда вытащить отформатированное значение
        // в виде интервала с помощью функции timeSince в расширении Date
//        let dateStr = conversation.messageDate
//        let timeStr = conversation.messageTime
        
        // Пока что ставим моковую дату
        let date = Date().addingTimeInterval(-15000)
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
