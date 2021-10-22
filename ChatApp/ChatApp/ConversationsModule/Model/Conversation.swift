//
//  Conversation.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import Foundation

/// Список секций диалогов
enum ConversationsSections: String, CaseIterable {
    case online = "Online"
    case history = "History"
}

/// Модель диалога
struct Conversation: Codable {
    var profileImageURL: String?
    var isOnline: Bool
    var userName: String?
    var lastMessage: String?
    var messageDate: String?
    var messageTime: String?
    var hasUnreadMessages: Bool?
}
