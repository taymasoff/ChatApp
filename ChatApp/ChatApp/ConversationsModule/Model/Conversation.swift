//
//  Conversation.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 05.10.2021.
//

import Foundation
import FirebaseFirestore
import UIKit

/// Модель диалога
struct Conversation {
    // Берем из DocumentID
    var identifier: String?
    
    // Декодим/Энкодим
    let name: String
    let lastMessage: String?
    var lastActivity: Date?
    
    // Вычисляем из lastActivity, не энкодим
    let isActive: Bool
    
    enum CodingKeys: CodingKey {
        case name
        case lastMessage
        case lastActivity
    }
}

// Рассчет активности
extension Conversation {
    // В течении скольки минут диалог будет считаться активным
    static let minutesToDefineConversationActive = 10
    static func hadActivityIn(minutes: Int,
                              lastActivity: Date?) -> Bool {
        guard let lastActivity = lastActivity else { return false }
        return lastActivity.minutesSince() < 10
    }
}

// MARK: - Decodable
extension Conversation: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        lastMessage = try values.decode(String.self, forKey: .lastMessage)
        lastActivity = try values.decode(Timestamp.self, forKey: .lastActivity).dateValue()

        isActive = Self.hadActivityIn(
            minutes: Self.minutesToDefineConversationActive,
            lastActivity: lastActivity
        )
    }
}

// MARK: - Encodable
extension Conversation: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(lastMessage, forKey: .lastMessage)
        // Энкодим по серверному времени
        if let lastActivity = lastActivity {
            try container.encode(
                Timestamp(date: lastActivity),
                forKey: .lastActivity
            )
        }
    }
}
