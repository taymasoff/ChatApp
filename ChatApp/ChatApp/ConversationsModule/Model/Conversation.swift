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
            return lastActivity.minutesSince() < Conversation.minutesToDefineConversationActive
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

// MARK: - CodingKeys
extension Conversation {
    enum CodingKeys: CodingKey {
        case name
        case lastMessage
        case lastActivity
    }
}

// MARK: - Decodable
extension Conversation: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // Нам 100% нужно имя, поэтому декодим его там
        if let name = try? values.decode(String.self, forKey: .name),
           name.isntEmptyOrWhitespaced {
            self.name = name
        } else {
            throw FirestoreError.emptyString
        }
        // Последнее сообщение и lastActivity не обязательно
        lastMessage = try values.decodeIfPresent(String.self, forKey: .lastMessage)
        if let lastActivity = try values.decodeIfPresent(Timestamp.self, forKey: .lastActivity) {
            self.lastActivity = lastActivity.dateValue()
        } else {
            self.lastActivity = nil
        }
    }
}

// MARK: - Encodable
extension Conversation: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // 100% нужно имя, поэтому кодим его
        try container.encode(name, forKey: .name)
        // По идее не нужно записывать lastMessage, но если вдруг
        // появится возможность создавать канал сразу с сообщением
        // записываем, если нету - то nil
        try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
        // Тут 100% не понятно, надо ли записывать текущую дату при создании канала,
        // Я записываю текущую дату по серверному времени
        if let date = lastActivity {
            try container.encode(Timestamp(date: date), forKey: .lastActivity)
        } else {
            try container.encodeNil(forKey: .lastActivity)
        }
    }
}
