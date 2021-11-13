//
//  GroupedMessages.swift
//  ChatApp
//
//  Created by Тимур Таймасов on 27.10.2021.
//

import Foundation

/// Модель сгруппированных сообщений. Используется для группировки по секциям.
struct GroupedMessages {
    let date: Date
    var messages: [Message]
    
    var numberOfItems: Int {
        return messages.count
    }

    subscript(index: Int) -> Message {
        return messages[index]
    }
}

// MARK: - Get Formatted Date
extension GroupedMessages {
    var formattedDate: String {
        if self.date.isToday() {
            return "Today"
        } else if self.date.isYesterday() {
            return "Yesterday"
        } else if self.date.isThisYear() {
            DateFormatter.shared.dateFormat = "MMMM d"
            return DateFormatter.shared.string(from: self.date)
        } else {
            DateFormatter.shared.dateFormat = "MMMM d, yyyy"
            return DateFormatter.shared.string(from: self.date)
        }
    }
}
