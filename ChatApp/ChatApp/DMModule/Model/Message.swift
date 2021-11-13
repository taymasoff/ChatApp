//
//  Message.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 07.10.2021.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

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

// MARK: - CodingKeys
extension Message {
    // Проверяем senderID и senderId потому что кодируют по разному
    enum CodingKeys: CodingKey {
        case content
        case created
        case senderID
        case senderId
        case senderName
    }
}

// MARK: - Decodable
extension Message: Decodable {
    init(from decoder: Decoder) throws {
        // Поля content и senderName тримим на лишние пробелы и символы начала строки
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let content = try? values.decode(String.self, forKey: .content) {
            self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw FirestoreDecodingError.fieldNameConflict("Message.content")
        }
        // У поля senderID обрабатываем оба варианта написания, т.к записывают по разному
        if let senderID = try? values.decode(String.self, forKey: .senderID) {
            self.senderID = senderID
        } else if let senderId = try? values.decode(String.self, forKey: .senderId) {
            self.senderID = senderId
        } else {
            throw FirestoreDecodingError.fieldNameConflict("Message.senderId/ID")
        }
        if let senderName = try? values.decode(String.self, forKey: .senderName) {
            self.senderName = senderName.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw FirestoreDecodingError.fieldNameConflict("Message.senderName")
        }
        if let created = try? values.decode(Timestamp.self, forKey: .created).dateValue() {
            self.created = created
        } else {
            throw FirestoreDecodingError.fieldNameConflict("Message.created")
        }
    }
}

// MARK: - Encodable
extension Message: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // При кодировании тоже на всякий случай вычищаем лишние пробелы
        try container.encode(
            content.trimmingCharacters(in: .whitespacesAndNewlines),
            forKey: .content)
        try container.encode(Timestamp(date: created), forKey: .created)
        try container.encode(senderID, forKey: .senderId)
        try container.encode(senderName, forKey: .senderName)
    }
}
