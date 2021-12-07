//
//  Message.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import Foundation

/// Список отправитель сообщения: сам пользователь или собеседник
enum MessageSender: CaseIterable {
    case friend
    case user
}

/// Модель сообщения
struct Message {
    let content: String
    let created: Date
    let senderID: String
    let senderName: String
    
    var sender: MessageSender {
        if senderID == AppData.deviceID {
            return .user
        } else {
            return .friend
        }
    }
}

// MARK: - QuickInit Option
extension Message {
    init(content: String) {
        self.content = content
        self.created = Date()
        self.senderID = AppData.deviceID
        self.senderName = AppData.currentUserName
    }
}

// MARK: - Domain Model
extension Message: DomainModel {
    
    var uniqueSearchPredicate: NSPredicate? {
        return NSPredicate(format: "created == %@",
                           self.created as NSDate)
    }
    
    var uniqueSearchString: String? {
        return "\(created)"
    }
    
    @discardableResult
    func insertInto(entity: DBMessage) -> DBMessage {
        entity.content = self.content
        entity.senderName = self.senderName
        entity.created = self.created
        entity.senderId = self.senderID
        return entity
    }
}
