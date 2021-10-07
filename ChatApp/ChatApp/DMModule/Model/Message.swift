//
//  Message.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import Foundation

/// Отправитель сообщения: сам пользователь или собеседник
enum MessageSender: CaseIterable {
    case friend
    case user
}

/// Модель сообщения
struct Message {
    var text: String?
    var time: String?
    var date: String?
    var sender: MessageSender?
}

/// Модель сгруппированных сообщений. Используется для группировки по секциям.
struct GroupedMessages {
    var groupName: String
    var messages: [Message]
}
