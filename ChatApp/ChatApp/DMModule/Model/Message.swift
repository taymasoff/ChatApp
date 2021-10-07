//
//  Message.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import Foundation

enum MessageSender: CaseIterable {
    case friend
    case user
}

struct Message {
    var text: String?
    var time: String?
    var date: String?
    var sender: MessageSender?
}

struct GroupedMessages {
    var groupName: String
    var messages: [Message]
}
