//
//  Conversation.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import Foundation
import FirebaseFirestore

/// Модель диалога
struct Conversation: FSIdentifiable {
    static let minutesToDefineConversationActive = 10
    
    // Не энкодим/не декодим, а берем из DocumentID
    var identifier: String?
    
    // Декодим/Энкодим
    let name: String
    let lastMessage: String?
    var lastActivity: Date?
    
    // Вычисляем активность
    var isActive: Bool {
        if let lastActivity = lastActivity {
            return lastActivity.minutesSince() < 10
        } else {
            return false
        }
    }
}

// MARK: - Quick Init Option
extension Conversation {
    init(name: String) {
        self.name = name
        self.lastActivity = Date()
        self.identifier = nil
        self.lastMessage = nil
    }
}

// MARK: - Domain Model
extension Conversation: DomainModel {
    var uniqueSearchPredicate: NSPredicate? {
        guard let id = identifier else { return nil }
        return NSPredicate(format: "identifier == %@", id)
    }
    
    var uniqueSearchString: String? {
        return identifier
    }
    
    @discardableResult
    func insertInto(entity: DBChannel) -> DBChannel {
        entity.identifier = self.identifier ?? UUID().uuidString
        entity.name = self.name
        entity.lastMessage = self.lastMessage
        entity.lastActivity = self.lastActivity
        return entity
    }
}
