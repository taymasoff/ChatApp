//
//  Conversation.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import Foundation

struct Conversation: Codable {
    var profileImageURL: String?
    var isOnline: Bool
    var userName: String?
    var lastMessage: String?
    var messageDate: String?
    var messageTime: String?
    var hasUnreadMessages: Bool?
}
