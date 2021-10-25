//
//  GroupedConversations.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 25.10.2021.
//

import Foundation

struct GroupedConversations {
    let title: String
    let conversations: [Conversation]

    var numberOfItems: Int {
        return conversations.count
    }

    subscript(index: Int) -> Conversation {
        return conversations[index]
    }
}
